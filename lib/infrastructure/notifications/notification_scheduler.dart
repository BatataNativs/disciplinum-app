import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/features/gamification/domain/services/gamification_messages.dart';
import 'package:disciplinum/infrastructure/iap/iap_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/models/common/niche.dart';
import 'package:disciplinum/features/modules/money_saving/domain/services/money_saving_challenge_service.dart';

class NotificationScheduler {
  static final NotificationScheduler _instance =
      NotificationScheduler._internal();
  static NotificationScheduler get instance => _instance;

  NotificationScheduler._internal();

  Future<void> scheduleNativeNotifications(
      NicheId nicheId, GamificationService service) async {
    debugPrint('📅 Configurando alarmes nativos para: ${nicheId.name}');

    // 1. Agendar Check-ins
    final checkIns = service.scheduleByModule[nicheId];
    if (checkIns != null) {
      for (int i = 0; i < checkIns.length; i++) {
        final time = checkIns[i];
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

        String body = GamificationMessages.getModuleMessage(
          nicheId,
          isUnlocked: IapService().isCustomNotifUnlocked ||
              service.isNotificationUnlocked(nicheId),
          customMessages: service.customMessages,
        );

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
          final timeStr =
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
          final timeStr =
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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

    // 2. Agendar Motivações (Frases)
    final motivations = service.motivationSchedulesByModule[nicheId];
    if (motivations != null && motivations.isNotEmpty) {
      for (int i = 0; i < motivations.length; i++) {
        final time = motivations[i];
        final notifId = (nicheId.id * 1000) + 500 + i;
        final niche = NicheRepository.getById(nicheId);
        final phrase = GamificationMessages.getMotivationalPhrase(
          nicheId,
          time,
          isUnlocked: IapService().isMotivationPhrasesUnlocked ||
              service.isMotivationUnlocked(nicheId),
          motivationSchedules: service.motivationSchedulesByModule,
          customPhrases: service.customPhrases,
          customMessages: service.customMessages,
        );

        await NotificationService.scheduleDailyNotification(
          id: notifId,
          time: time,
          title: 'Disciplinum: ${niche.name}',
          body: phrase,
        );
      }
    }

    // 3. Agendar Desafio da Poupança (Módulo 7)
    if (nicheId == NicheId.moneySavingChallenge) {
      await scheduleChallengeNotification(service);
    }
  }

  Future<void> scheduleChallengeNotification(
      GamificationService service) async {
    try {
      final challenge =
          await MoneySavingChallengeService().getActiveChallenge();
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
      final body = GamificationMessages.getModuleMessage(
        NicheId.moneySavingChallenge,
        isUnlocked: IapService().isCustomNotifUnlocked ||
            service.isNotificationUnlocked(NicheId.moneySavingChallenge),
        customMessages: service.customMessages,
      );
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
      debugPrint('Erro ao agendar notificação do desafio: $e');
    }
  }

  Future<void> cancelModuleNotifications(NicheId nicheId) async {
    debugPrint('🔕 Cancelando notificações para o módulo: ${nicheId.name}');
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
