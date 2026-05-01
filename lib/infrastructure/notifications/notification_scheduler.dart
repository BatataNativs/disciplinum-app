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
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_motivational_phrase_service.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';

class NotificationScheduler {
  static final NotificationScheduler _instance =
      NotificationScheduler._internal();
  static NotificationScheduler get instance => _instance;

  NotificationScheduler._internal();

  /// Obtém horários de check-in/notificações para um módulo específico
  /// NOTA: Apenas Smoking tem check-in diário.
  /// 
  /// Busca horários da cloud (Supabase) com fallback local (ObjectBox)
  Future<List<String>> _getModuleCheckInTimes(NicheId nicheId) async {
    if (nicheId == NicheId.smoking) {
      try {
        // Usar ProviderContainer para acessar o CloudSyncService
        final container = ProviderContainer();
        final cloudSyncService = container.read(cloudSyncServiceProvider);
        final userNicheTimes = await cloudSyncService.loadUserNicheTimes(
          nicheId: nicheId.id,
        );
        
        // Converter UserNicheTime para String no formato "HH:mm"
        final times = userNicheTimes.map((t) => 
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}'
        ).toList();
        
        if (times.isNotEmpty) {
          LoggerService.instance.i('Horários de check-in carregados da cloud/local: ${times.length} horários');
          return times;
        } else {
          // Fallback: horário padrão se não houver configuração
          LoggerService.instance.w('Nenhum horário configurado, usando padrão 20:00');
          return ['20:00'];
        }
      } catch (e) {
        LoggerService.instance.e('Erro ao carregar horários de check-in', error: e);
        // Fallback em caso de erro
        return ['20:00'];
      }
    }
    return [];
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

    // 3. Agendar Motivações (Frases) - APENAS para Smoking
    // Frases motivacionais contextualizadas baseadas nas conquistas do usuário
    if (nicheId == NicheId.smoking) {
      await _scheduleSmokingMotivationalNotifications(nicheId);
    }

    // 3. Agendar Desafio da Poupança (Módulo 7)
    if (nicheId == NicheId.moneySavingChallenge) {
      await scheduleChallengeNotification(iapService);
    }
  }

  // NOTA: MoneySaving já implementado com provider local
  // Usa moneySavingChallengeServiceProvider via ProviderContainer

  Future<void> scheduleChallengeNotification(
      IapService iapService) async {
    try {
      // Dependency injection via ProviderContainer
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

  /// Agenda notificações motivacionais contextualizadas para o módulo Smoking
  ///
  /// Busca dados de gamificação do usuário e gera frases personalizadas
  /// baseadas nas conquistas recentes (insígnias e medalhas).
  Future<void> _scheduleSmokingMotivationalNotifications(NicheId nicheId) async {
    try {
      LoggerService.instance.i('📢 Agendando notificações motivacionais do Smoking...');

      // Buscar dados de gamificação do Smoking
      final gamificationData = await SmokingGamificationRepository.instance.getGamificationData();

      if (gamificationData == null) {
        LoggerService.instance.w('Dados de gamificação do Smoking não encontrados');
        return;
      }

      // Extrair conquistas do mapa
      final earnedInsignias = List<String>.from(gamificationData['insignias'] ?? []);
      final earnedMedalhas = List<String>.from(gamificationData['medalhas'] ?? []);
      final daysWithoutSmoking = gamificationData['consecutiveDays'] ?? 0;

      LoggerService.instance.i(
        '🏆 Conquistas: ${earnedInsignias.length} insígnias, ${earnedMedalhas.length} medalhas, $daysWithoutSmoking dias'
      );

      // Horários padrão para notificações motivacionais (3x ao dia)
      final notificationTimes = [
        const TimeOfDay(hour: 9, minute: 0),   // Manhã
        const TimeOfDay(hour: 14, minute: 0),  // Tarde
        const TimeOfDay(hour: 20, minute: 0), // Noite
      ];

      // Agenda notificações para cada horário
      for (int i = 0; i < notificationTimes.length; i++) {
        final time = notificationTimes[i];

        // Gera frase motivacional contextualizada
        final phrase = SmokingMotivationalPhraseService().generateMotivationalPhrase(
          earnedInsignias: earnedInsignias,
          earnedMedalhas: earnedMedalhas,
          daysWithoutSmoking: daysWithoutSmoking,
          currentTime: time,
        );

        final notifId = (nicheId.id * 1000) + 500 + i;

        await NotificationService.scheduleDailyNotification(
          id: notifId,
          time: time,
          title: '📢 Disciplinum: Smoking',
          body: phrase,
        );

        LoggerService.instance.i(
          '✅ Notificação ${i + 1}/${notificationTimes.length} agendada: ${time.hour}:${time.minute.toString().padLeft(2, '0')}'
        );
      }

      LoggerService.instance.i('✅ Notificações motivacionais do Smoking agendadas!');
    } catch (e, stackTrace) {
      LoggerService.instance.e(
        'Erro ao agendar notificações motivacionais do Smoking',
        error: e,
        stackTrace: stackTrace,
      );
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
