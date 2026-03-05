import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/services/permissions/notifications/notification_service.dart';
import 'package:disciplinum/services/cloud/cloud_sync_service.dart';
import 'package:disciplinum/models/niche_id.dart';
import 'package:disciplinum/models/niche.dart';
import 'package:disciplinum/models/gamification/medal.dart';
import 'package:disciplinum/models/gamification/insignia.dart';

class GamificationAwardEngine {
  static final GamificationAwardEngine _instance =
      GamificationAwardEngine._internal();
  static GamificationAwardEngine get instance => _instance;

  GamificationAwardEngine._internal();

  /// Concede uma insígnia de Foco ao usuário.
  Future<void> awardInsignia(
      FocusInsignia insignia, GamificationService service) async {
    if (service.earnedFocusInsignias.contains(insignia)) return;

    service.addEarnedFocusInsignia(insignia);
    await service.saveFocusInsignias();

    final niche = NicheRepository.getById(NicheId.focus);
    final data = {
      'type': 'focus_insignia',
      'insignia_name': insignia.nameBr,
      'insignia_key': insignia.toString().split('.').last,
      'insignia_asset': insignia.asset,
      'module_name': niche.name,
      'awarded_at': DateTime.now().toIso8601String(),
    };

    service.addPendingInsignia(data);
    await _sendInsigniaNotification(insignia, niche.name);

    await CloudSyncService.saveModuleStatus(
      nicheId: NicheId.focus,
      isActive: true,
      earnedInsignias: service.earnedFocusInsignias
          .map((e) => e.toString().split('.').last)
          .toList(),
    );
  }

  Future<void> _sendInsigniaNotification(
      FocusInsignia insignia, String moduleName) async {
    AndroidBitmap<Uint8List>? largeIcon;
    try {
      final ByteData data = await rootBundle.load(insignia.asset);
      largeIcon = ByteArrayAndroidBitmap(data.buffer.asUint8List());
    } catch (_) {}

    final body =
        'Parabéns 🎊 Você obteve a insígnia ${insignia.nameBr} no módulo $moduleName!';
    final androidDetails = AndroidNotificationDetails(
      'disciplinum_insignias',
      'Insígnias Disciplinum',
      importance: Importance.max,
      priority: Priority.high,
      playSound: NotificationService.soundEnabled,
      largeIcon: largeIcon,
      styleInformation: BigTextStyleInformation(body),
      actions: [
        const AndroidNotificationAction('view_insignia', 'Ver no app',
            showsUserInterface: true, cancelNotification: true)
      ],
    );
    await flutterLocalNotificationsPlugin.show(
        5000 + insignia.index,
        'Nova Insígnia Conquistada! 🎖️',
        body,
        NotificationDetails(android: androidDetails));
  }

  void awardMedal(
      NicheId nicheId, GamificationMedal medal, GamificationService service) {
    final medalData = {
      'niche_id': nicheId.id,
      'medal_name': medal.nameBr,
      'medal_asset': medal.asset,
      'awarded_at': DateTime.now().toIso8601String(),
    };

    service.addPendingMedal(medalData);
    _sendMedalNotificationWithActions(nicheId, medal);
  }

  Future<void> _sendMedalNotificationWithActions(
      NicheId nicheId, GamificationMedal medal) async {
    final title = 'Nova Medalha Conquistada! 🏆';
    final body =
        'Parabéns! Você alcançou a medalha de ${medal.nameBr} no módulo ${NicheRepository.getById(nicheId).name}.';

    AndroidBitmap<Uint8List>? largeIcon;
    try {
      final ByteData data = await rootBundle.load(medal.asset);
      largeIcon = ByteArrayAndroidBitmap(data.buffer.asUint8List());
    } catch (_) {}

    final androidDetails = AndroidNotificationDetails(
        'disciplinum_medals', 'Conquistas e Medalhas',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        largeIcon: largeIcon,
        styleInformation: BigTextStyleInformation(body),
        actions: [
          const AndroidNotificationAction('view_app', 'Ver no app',
              showsUserInterface: true),
          const AndroidNotificationAction('dismiss_medal', 'Ok. Apagar',
              showsUserInterface: false, cancelNotification: true),
        ]);
    await flutterLocalNotificationsPlugin.show(nicheId.id + 900, title, body,
        NotificationDetails(android: androidDetails));
  }

  void checkTimeBasedMedals(NicheId nicheId, GamificationService service) {
    final startDate = service.getModuleStartDate(nicheId);
    if (startDate == null) return;

    final daysActive = DateTime.now().difference(startDate).inDays;
    if (daysActive <= 0) return;

    if (daysActive != service.diasConsecutivosByModule[nicheId]) {
      service.updateConsecutiveDays(nicheId, daysActive);
      _verificaMedalhaDias(nicheId, daysActive, service);
    }
  }

  void _verificaMedalhaDias(
      NicheId nicheId, int dias, GamificationService service) {
    GamificationMedal? newMedal;
    if (dias >= 10) {
      newMedal = GamificationMedal.diamante;
    } else if (dias >= 7) {
      newMedal = GamificationMedal.ouro;
    } else if (dias >= 5) {
      newMedal = GamificationMedal.prata;
    } else if (dias >= 3) {
      newMedal = GamificationMedal.bronze;
    }

    final current = service.maxMedalForModule(nicheId);
    if (newMedal != null &&
        (current == null || newMedal.index > current.index)) {
      service.setMaxMedal(nicheId, newMedal);
      awardMedal(nicheId, newMedal, service);
    }
    if (nicheId == NicheId.focus) _verificaInsigniasFoco(dias, service);
  }

  void _verificaInsigniasFoco(int dias, GamificationService service) {
    for (final insignia in FocusInsignia.values) {
      if (insignia == FocusInsignia.ferro) continue;
      if (dias >= insignia.requiredDays) awardInsignia(insignia, service);
    }
  }
}
