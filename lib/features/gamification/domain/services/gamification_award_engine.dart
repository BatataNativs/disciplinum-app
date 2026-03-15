import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/gamification/domain/entities/medal.dart';
import 'package:disciplinum/features/gamification/domain/entities/insignia.dart';

class GamificationAwardEngine {
  static final GamificationAwardEngine _instance =
      GamificationAwardEngine._internal();
  static GamificationAwardEngine get instance => _instance;

  GamificationAwardEngine._internal();

  static const Map<int, FocusInsignia> _focusMilestones = {
    0: FocusInsignia.madeira,
    1: FocusInsignia.ferro,
    2: FocusInsignia.aluminio,
    3: FocusInsignia.latao,
    4: FocusInsignia.bronze,
    5: FocusInsignia.prata,
    6: FocusInsignia.ouro,
    9: FocusInsignia.diamante,
    10: FocusInsignia.disciplinum,
  };

  bool _isReconcilingFocusInsignias = false;

  /// Concede uma insígnia de Foco ao usuário.
  Future<void> awardInsignia(
      FocusInsignia insignia, GamificationService service) async {
    if (service.earnedFocusInsignias.contains(insignia)) return;

    service.addEarnedFocusInsignia(insignia);
    await service.saveFocusInsignias();

    final niche = NicheRepository.getById(NicheId.focus);
    final data = {
      'type': 'focus_insignia',
      'insignia_name': insignia.nameBr.split(' ').last, // CORRIGIDO: Pega apenas "Madeira", "Ferro", etc.
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
    ).catchError((e) => LoggerService.instance.e('Erro Sync awardFocusInsignia', error: e));
  }

  Future<void> _sendInsigniaNotification(
      FocusInsignia insignia, String moduleName) async {
    AndroidBitmap<Uint8List>? largeIcon;
    try {
      final ByteData data = await rootBundle.load(insignia.asset);
      largeIcon = ByteArrayAndroidBitmap(data.buffer.asUint8List());
    } catch (_) {}

    final body =
        'Parabéns 🎊 Você obteve a insígnia ${insignia.nameBr.split(' ').last} no módulo $moduleName!';
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
            showsUserInterface: true, cancelNotification: false), // CORRIGIDO: cancelNotification: false
        const AndroidNotificationAction('dismiss_insignia', 'Ok. Guardar',
            showsUserInterface: false, cancelNotification: true),
      ],
    );
    await flutterLocalNotificationsPlugin.show(
        5000 + insignia.index,
        'Nova Insígnia Conquistada! 🎖️',
        body,
        NotificationDetails(android: androidDetails));
  }

  Future<void> awardMedal(
      NicheId nicheId, GamificationMedal medal, GamificationService service) async {
    final medalData = {
      'niche_id': nicheId.id,
      'medal_name': medal.nameBr,
      'medal_asset': medal.asset,
      'awarded_at': DateTime.now().toIso8601String(),
    };

    service.addPendingMedal(medalData);
    await _sendMedalNotificationWithActions(nicheId, medal);
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
    final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
    await flutterLocalNotificationsPlugin.show(id, title, body,
        NotificationDetails(android: androidDetails));
  }

  Future<void> checkTimeBasedMedals(NicheId nicheId, GamificationService service) async {
    final startDate = service.getModuleStartDate(nicheId);
    if (startDate == null) return;

    // Para módulo Foco, usar períodos de foco respeitados em vez de dias
    if (nicheId == NicheId.focus) {
      final periodosRespeitados = service.getRespectedFocusPeriods(nicheId);
      await _verificaMedalhaDias(nicheId, periodosRespeitados, service);
      return;
    }

    // Para outros módulos, manter lógica de dias corridos
    final daysActive = DateTime.now().difference(startDate).inDays;

    if (daysActive != service.diasConsecutivosByModule[nicheId]) {
      service.updateConsecutiveDaysSync(nicheId, daysActive);
      await _verificaMedalhaDias(nicheId, daysActive, service);
    }
  }

  Future<void> _verificaMedalhaDias(
      NicheId nicheId, int dias, GamificationService service) async {
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
      await awardMedal(nicheId, newMedal, service);
    }
    // REMOVIDO: Insígnias de foco agora são verificadas separadamente
  }

  // Método para concessão silenciosa (sem notificação) - usado em reconciliação
  Future<void> _grantInsigniaSilently(
      FocusInsignia insignia, GamificationService service) async {
    if (service.earnedFocusInsignias.contains(insignia)) return;

    service.addEarnedFocusInsignia(insignia);
    await service.saveFocusInsignias();

    await CloudSyncService.saveModuleStatus(
      nicheId: NicheId.focus,
      isActive: true,
      earnedInsignias: service.earnedFocusInsignias
          .map((e) => e.toString().split('.').last)
          .toList(),
    ).catchError((e) => LoggerService.instance.e('Erro Sync _grantInsigniaSilently', error: e));
  }

  // MÉTODO CORRIGIDO: Concede apenas insígnia exata do marco atual
  Future<void> checkFocusInsigniasByPeriods(
      NicheId nicheId, GamificationService service) async {
    if (nicheId != NicheId.focus) return;
   
    final periodosRespeitados = service.getRespectedFocusPeriods(nicheId);
    final target = _focusMilestones[periodosRespeitados];
    if (target == null) return;
    if (service.earnedFocusInsignias.contains(target)) return;

    await awardInsignia(target, service);
  }

  // MÉTODO NOVO: Reconcilia insígnias faltantes sem notificação
  Future<void> reconcileFocusInsignias(
      NicheId nicheId, GamificationService service) async {
    if (nicheId != NicheId.focus) return;
    if (_isReconcilingFocusInsignias) return;

    _isReconcilingFocusInsignias = true;
    try {
      final periodosRespeitados = service.getRespectedFocusPeriods(nicheId);

      for (final entry in _focusMilestones.entries) {
        if (entry.key > periodosRespeitados) continue;
        await _grantInsigniaSilently(entry.value, service);
      }
    } finally {
      _isReconcilingFocusInsignias = false;
    }
  }
}
