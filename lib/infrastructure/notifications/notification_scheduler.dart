import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
// NOTA: Implementação parcial com providers locais - GamificationService removido
// Cada módulo agora gerencia suas próprias notificações via providers específicos
import 'package:disciplinum/infrastructure/iap/iap_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/diet/data/repositories/diet_config_repository.dart';

class NotificationScheduler {
  static final NotificationScheduler _instance =
      NotificationScheduler._internal();
  static NotificationScheduler get instance => _instance;

  NotificationScheduler._internal();

  /// Obtém horários de check-in/notificações para um módulo específico
  /// NOTA: Apenas Smoking tem check-in diário.
  /// Diet tem notificações de refeição (30min antes e depois).
  /// Outros módulos usam AppLock ou métricas diferentes.
  Future<List<String>> _getModuleCheckInTimes(NicheId nicheId) async {
    try {
      switch (nicheId) {
        // ✅ Apenas Smoking tem check-in diário (user define horário)
        case NicheId.smoking:
          return ['20:00']; // Horário padrão, pode ser configurável
          
        // ❌ Sem check-in diário - usam AppLock ou outras métricas
        case NicheId.adultContent:
        case NicheId.bingeEating:
        case NicheId.spending:
        case NicheId.moneySavingChallenge:
        case NicheId.focus:
        case NicheId.procrastination:
        case NicheId.diet:
        case NicheId.reading:
          return [];
      }
    } catch (e) {
      LoggerService.instance.w('Erro ao obter horários de check-in para $nicheId: $e');
      return [];
    }
  }

  /// Agenda notificações de refeição para o módulo Diet
  /// - Notificação 30min ANTES do horário (lembrete para preparar)
  /// - Notificação 30min DEPOIS do horário (confirmação se fez)
  Future<void> _scheduleDietMealNotifications(List<String> mealTimes) async {
    for (int i = 0; i < mealTimes.length; i++) {
      final timeStr = mealTimes[i];
      final timeParts = timeStr.split(':');
      final mealHour = int.parse(timeParts[0]);
      final mealMinute = int.parse(timeParts[1]);
      
      final now = DateTime.now();
      final mealTime = DateTime(now.year, now.month, now.day, mealHour, mealMinute);
      
      // 1. Notificação 30min ANTES (lembrete para preparar)
      final reminderTime = mealTime.subtract(const Duration(minutes: 30));
      final notifIdBefore = (NicheId.diet.id * 1000) + 200 + i;
      
      await NotificationService.scheduleDailyNotification(
        id: notifIdBefore,
        time: TimeOfDay(hour: reminderTime.hour, minute: reminderTime.minute),
        title: '🍽️ Hora de preparar a refeição!',
        body: 'Sua refeição das $timeStr está chegando. Prepare-se!',
      );
      
      // 2. Notificação 30min DEPOIS (confirmação)
      final confirmTime = mealTime.add(const Duration(minutes: 30));
      final notifIdAfter = (NicheId.diet.id * 1000) + 300 + i;
      final isLastMeal = i == mealTimes.length - 1;
      
      await NotificationService.scheduleDailyNotification(
        id: notifIdAfter,
        time: TimeOfDay(hour: confirmTime.hour, minute: confirmTime.minute),
        title: isLastMeal ? '🎉 Última refeição do dia!' : '✅ Refeição confirmada?',
        body: 'Você fez a refeição das $timeStr? ${isLastMeal ? "Confirme para ganhar sua insígnia!" : ""}',
        actions: [
          const AndroidNotificationAction('DIET_SIM', 'Sim, fiz!',
              showsUserInterface: true, cancelNotification: true),
          const AndroidNotificationAction('DIET_NAO', 'Não fiz',
              showsUserInterface: true, cancelNotification: true),
        ],
        payload: isLastMeal ? 'diet_last_meal_$timeStr' : 'diet_meal_$timeStr',
      );
    }
  }

  // NOTA: Providers locais implementados - cada módulo tem seu próprio provider de notificações
  // MoneySaving: usa moneySavingChallengeServiceProvider (já implementado abaixo)
  // Reading: implementado em reading_screen.dart
  // Outros módulos: implementação local em seus respectivos providers
  Future<void> scheduleNativeNotifications(
      NicheId nicheId, IapService iapService) async {
    LoggerService.instance.d('📅 Configurando alarmes nativos para: ${nicheId.name}');

    // 1. Agendar Check-ins usando providers locais de cada módulo
    final checkIns = await _getModuleCheckInTimes(nicheId);
    if (checkIns.isNotEmpty) {
      for (int i = 0; i < checkIns.length; i++) {
        final timeStr = checkIns[i];
        final timeParts = timeStr.split(':');
        final time = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
        final notifId = (nicheId.id * 1000) + 100 + i;
        final niche = NicheRepository.getById(nicheId);

        List<AndroidNotificationAction>? actions;
        String? payload;

        if (nicheId == NicheId.smoking) {
          payload = nicheId.id.toString();
          actions = [
            const AndroidNotificationAction(actionIdSim, 'Sim!',
                showsUserInterface: true, cancelNotification: true),
            const AndroidNotificationAction(actionIdNao, 'Não, tive recaída',
                showsUserInterface: true, cancelNotification: true),
          ];
        } else if (nicheId == NicheId.bingeEating) {
          payload = 'binge_checkin';
          actions = [
            const AndroidNotificationAction(actionIdBingeSim, 'Resisti',
                showsUserInterface: true, cancelNotification: true),
            const AndroidNotificationAction(actionIdBingeNao, 'Não resisti',
                showsUserInterface: true, cancelNotification: true),
          ];
        }

        String body = "Mensagem padrão do check-in"; // Temporário

        if (nicheId == NicheId.smoking) {
          body =
              'Manteve-se disciplinado hoje? \n\nLembre-se de conferir seu progresso no app 🚀.';
        } else if (nicheId == NicheId.bingeEating) {
          body =
              'Você resistiu às tentações de delivery hoje? \n\nMarque "resisti" e registre seu progresso no app 🚀.';
        }

        if (nicheId == NicheId.procrastination) {
          payload = 'procrastination_checkin';
          actions = [
            const AndroidNotificationAction(
              'ver_itens',
              'Ver itens agendados',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ];
        }

        TimeOfDay finalTime = time;
        if (nicheId == NicheId.diet) {
          payload = 'diet_meal_$timeStr';
          actions = [
            const AndroidNotificationAction('DIET_SIM', 'Fiz/Farei refeição',
                showsUserInterface: true, cancelNotification: true),
            const AndroidNotificationAction('DIET_NAO', 'Não fiz/não farei',
                showsUserInterface: true, cancelNotification: true),
          ];
          body = 'Hora da refeição das $timeStr! Você fez/fará esta refeição?';

          final now = DateTime.now();
          var scheduledDateTime =
              DateTime(now.year, now.month, now.day, time.hour, time.minute);
          scheduledDateTime =
              scheduledDateTime.subtract(const Duration(minutes: 30));
          finalTime = TimeOfDay(
              hour: scheduledDateTime.hour, minute: scheduledDateTime.minute);
        }

        if (nicheId == NicheId.reading) {
          payload = 'reading_reminder_$timeStr';
          body =
              '📚 Hora da leitura diária! Vamos viajar mais um pouco no mundo dos livros?';
        }

        await NotificationService.scheduleDailyNotification(
          id: notifId,
          time: finalTime,
          title: 'Check-in Diário: ${niche.name}',
          body: body,
          actions: actions,
          payload: payload,
        );
      }
    }

    // 2. Agendar notificações de refeição para Diet (30min antes e depois)
    if (nicheId == NicheId.diet) {
      // Buscar horários reais do DietConfigRepository
      final config = await DietConfigRepository.instance.getConfig();
      final mealTimes = config?.mealTimes ?? [];
      if (mealTimes.isNotEmpty) {
        await _scheduleDietMealNotifications(mealTimes);
      }
    }

    // 3. Agendar Motivações (Frases)
    // NOTA: Frases motivacionais agora são gerenciadas localmente por cada módulo
    // Implementação específica em cada provider de gamificação
    final motivations = <String>[]; // Temporário
    if (motivations.isNotEmpty) {
      for (int i = 0; i < 10; i++) {
        final motTimeStr = "10:00"; // Temporário
        final motParts = motTimeStr.split(':');
        final motTime = TimeOfDay(
          hour: int.parse(motParts[0]),
          minute: int.parse(motParts[1]),
        );
        final notifId = (nicheId.id * 1000) + 500 + i;
        final niche = NicheRepository.getById(nicheId);
        final phrase = "Frase motivacional padrão"; // Temporário

        await NotificationService.scheduleDailyNotification(
          id: notifId,
          time: motTime,
          title: 'Disciplinum: ${niche.name}',
          body: phrase,
        );
      }
    }

    // 3. Agendar Desafio da Poupança (Módulo 7)
    if (nicheId == NicheId.moneySavingChallenge) {
      await scheduleChallengeNotification(iapService);
    }
  }

  // NOTA: MoneySaving já implementado com provider local
  // Usa moneySavingChallengeServiceProvider via ProviderContainer
  // Future<void> scheduleChallengeNotification(
  //     GamificationService service, IapService iapService) async {
  Future<void> scheduleChallengeNotification(
      IapService iapService) async {
    try {
      // Dependency injection via ProviderContainer
      // Note: Since NotificationScheduler is a singleton, we need to create a container
      final container = ProviderContainer();
      final challengeService = container.read(moneySavingChallengeServiceProvider);
      
      await challengeService.getChallenges();
      final challenge = challengeService.activeChallenge;
      
      if (challenge == null || challenge.notifFrequency == 'disabled') {
        await NotificationService.cancelNotification(7001);
        return;
      }

      final timeParts = challenge.notifTime.split(':');
      final time = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );

      final title = 'Desafio da Poupança 💰';
      final body = "Mensagem padrão do desafio"; // Temporário
      const int notifId = 7001;

      await NotificationService.cancelNotification(notifId);

      switch (challenge.notifFrequency) {
        case 'diario':
          await NotificationService.scheduleDailyNotification(
            id: notifId,
            time: time,
            title: title,
            body: body,
          );
          break;
        case 'semanal':
          await NotificationService.scheduleWeeklyNotification(
            id: notifId,
            dayOfWeek: challenge.notifDayOfWeek,
            time: time,
            title: title,
            body: body,
          );
          break;
        case 'mensal':
          await NotificationService.scheduleMonthlyNotification(
            id: notifId,
            dayOfMonth: challenge.notifDayOfMonth,
            time: time,
            title: title,
            body: body,
          );
          break;
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao agendar notificação do desafio', error: e);
    }
  }

  Future<void> cancelModuleNotifications(NicheId nicheId) async {
    LoggerService.instance.d('🔕 Cancelando notificações para o módulo: ${nicheId.name}');
    for (int i = 0; i < 10; i++) {
      await NotificationService.cancelNotification(
          (nicheId.id * 1000) + 100 + i);
    }
    for (int i = 0; i < 10; i++) {
      await NotificationService.cancelNotification(
          (nicheId.id * 1000) + 500 + i);
    }
    if (nicheId == NicheId.moneySavingChallenge) {
      await NotificationService.cancelNotification(7001);
    }
  }
}
