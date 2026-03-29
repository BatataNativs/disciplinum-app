import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:disciplinum/services/gamification/gamification_service.dart';
import 'package:disciplinum/infrastructure/permissions/notifications/notification_service.dart';
import 'package:disciplinum/features/modules/focus/domain/services/focus_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service.dart';
import 'package:disciplinum/features/modules/diet/domain/services/diet_service.dart';
import 'package:disciplinum/infrastructure/cloud/cloud_sync_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';
import 'package:disciplinum/shared/repositories/niche_repository.dart';
import 'package:disciplinum/features/gamification/domain/entities/medal.dart';
import 'package:disciplinum/features/gamification/domain/entities/insignia.dart';

// TODO: Remover estas classes após migração completa - estão sendo movidas para módulos específicos
class AdultContentEvent {
  static const String blocked = 'adult_content_blocked';
  static const String accessed = 'adult_content_accessed';
  static const String limitReached = 'adult_content_limit_reached';
  static const String streakExtended = 'adult_content_streak_extended';
}

class DietEvent {
  static const String goalCompleted = 'diet_goal_completed';
  static const String mealCompleted = 'diet_meal_completed';
  static const String streakExtended = 'diet_streak_extended';
  static const String nutritionGoal = 'diet_nutrition_goal';
}

class GamificationAwardEngine {
  final CloudSyncService _cloudSync;

  GamificationAwardEngine(this._cloudSync);

  static const Map<int, FocusInsignia> _focusMilestones = {
    0: FocusInsignia.madeira,      // 🪵 Madeira - (apenas por configurar e ativar o módulo já ganha)
    1: FocusInsignia.ferro,       // 🥈 Ferro - 1 período de foco respeitado
    2: FocusInsignia.aluminio,    // 🥈 Alumínio - 2 períodos de foco respeitado
    3: FocusInsignia.latao,        // 🥇 Latão - 3 períodos de foco respeitado
    4: FocusInsignia.bronze,       // 🥉 Bronze - 4 períodos de foco respeitado
    5: FocusInsignia.prata,       // 🥈 Prata - 5 períodos de foco respeitado
    6: FocusInsignia.ouro,        // 🥇 Ouro - 6 períodos de foco respeitado
    9: FocusInsignia.diamante,    // 💎 Diamante - 9 períodos de foco respeitado
    10: FocusInsignia.disciplinum, // 🏆 Disciplinum - 10 períodos de foco respeitado
  };

  bool _isReconcilingFocusInsignias = false;

  /// Concede uma insígnia de Foco ao usuário.
  Future<void> awardInsignia(
      FocusInsignia insignia,
      FocusService focusService,
  ) async {
    final earned = await focusService.getEarnedInsignias();
    if (earned.contains(insignia)) return;

    await focusService.awardInsignia(insignia);

    final niche = NicheRepository.getById(NicheId.focus);

    // Opcional: Notificar UI via outro mecanismo se não houver service
    await _sendInsigniaNotification(insignia, niche.name);

    // Log do evento de insignia concedida
    LoggerService.instance.i('Insignia concedida: ${insignia.nameBr}');

    final currentEarned = await focusService.getEarnedInsignias();
    await _cloudSync.saveModuleStatus(
      nicheId: NicheId.focus,
      isActive: true,
      earnedInsignias: currentEarned
          .map((e) => e.toString().split('.').last)
          .toList(),
    ).catchError((e) => LoggerService.instance.e('Erro Sync awardFocusInsignia', error: e));
  }

  /// Concede medalha ao usuário
  Future<void> awardMedal(
      NicheId nicheId,
      GamificationMedal medal,
      GamificationService service,
  ) async {
    final medalData = {
      'niche_id': nicheId.id,
      'medal_name': medal.nameBr,
      'medal_asset': medal.asset,
      'awarded_at': DateTime.now().toIso8601String(),
    };
    service.addPendingMedal(jsonEncode(medalData));
    await _sendMedalNotificationWithActions(nicheId, medal);
  }

  /// Verifica e concede medalhas baseadas em tempo
  Future<void> checkTimeBasedMedals(
      NicheId nicheId,
      GamificationService service,
      FocusService focusService,
  ) async {
    final startDate = service.getModuleStartDate(nicheId.id);
    if (startDate == null) return;

    // Para módulo Foco, usar períodos de foco respeitados em vez de dias
    if (nicheId == NicheId.focus) {
      final periodosRespeitados = await focusService.getRespectedPeriods();
      await _verificaMedalhaDias(nicheId, periodosRespeitados, service);
      return;
    }

    // Para outros módulos, manter lógica de dias corridos
    final daysActive = DateTime.now().difference(startDate).inDays;

    if (daysActive != service.diasConsecutivosByModule[nicheId.id]) {
      service.updateConsecutiveDaysSync(nicheId.id, daysActive);
      await _verificaMedalhaDias(nicheId, daysActive, service);
    }
  }

  /// Verifica medalhas baseadas em dias corridos
  Future<void> _verificaMedalhaDias(
      NicheId nicheId,
      int dias,
      GamificationService service,
  ) async {
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

    final current = service.maxMedalForModule(nicheId.id);
    if (newMedal != null && newMedal.index > current) {
      service.setMaxMedal(nicheId.id, newMedal.index);
      await awardMedal(nicheId, newMedal, service);
    }
  }

  /// Método para concessão silenciosa (sem notificação) - usado em reconciliação
  Future<void> _grantInsigniaSilently(
      FocusInsignia insignia,
      FocusService focusService,
  ) async {
    final earned = await focusService.getEarnedInsignias();
    if (earned.contains(insignia)) return;

    await focusService.awardInsignia(insignia);

    final currentEarned = await focusService.getEarnedInsignias();
    await _cloudSync.saveModuleStatus(
      nicheId: NicheId.focus,
      isActive: true,
      earnedInsignias: currentEarned
          .map((e) => e.toString().split('.').last)
          .toList(),
    ).catchError((e) => LoggerService.instance.e('Erro Sync _grantInsigniaSilently', error: e));
  }

  /// MÉTODO NOVO: Concede insígnia Madeira na ativação do módulo
  Future<void> awardMadeiraOnActivation(
      FocusService focusService,
  ) async {
    LoggerService.instance.d('🎮 awardMadeiraOnActivation chamado');
    final earned = await focusService.getEarnedInsignias();
    if (earned.contains(FocusInsignia.madeira)) {
      LoggerService.instance.d('🎮 Madeira já foi concedida, ignorando');
      return;
    }

    LoggerService.instance.d('🎮 Concedendo insígnia Madeira');
    await awardInsignia(FocusInsignia.madeira, focusService);
  }

  /// MÉTODO CORRIGIDO: Concede apenas insígnia exata do marco atual (exceto Madeira que é concedida na ativação)
  Future<void> checkFocusInsigniasByPeriods(
      NicheId nicheId,
      FocusService focusService,
  ) async {
    if (nicheId != NicheId.focus) return;
   
    final periodosRespeitados = await focusService.getRespectedPeriods();
    final target = _focusMilestones[periodosRespeitados];
    
    LoggerService.instance.d('🎮 checkFocusInsigniasByPeriods: períodos=$periodosRespeitados, target=$target');
    
    if (target == null) {
      LoggerService.instance.d('🎮 Nenhuma insígnia para este período');
      return;
    }

    final earned = await focusService.getEarnedInsignias();
    if (earned.contains(target)) {
      LoggerService.instance.d('🎮 Insígnia $target já foi concedida');
      return;
    }
    
    // CORREÇÃO: Não conceder Madeira (índice 0) aqui - ela é concedida na ativação do módulo
    if (periodosRespeitados == 0) {
      LoggerService.instance.d('🎮 Período 0, não conceder Madeira aqui');
      return;
    }

    LoggerService.instance.d('🎮 Concedendo insígnia $target para período $periodosRespeitados');
    await awardInsignia(target, focusService);
  }

  /// MÉTODO CORRIGIDO: Reconcilia apenas insígnias faltantes sem notificação
  Future<void> reconcileFocusInsignias(
      NicheId nicheId,
      FocusService focusService,
  ) async {
    if (nicheId != NicheId.focus) return;
    if (_isReconcilingFocusInsignias) return;

    _isReconcilingFocusInsignias = true;
    try {
      final periodosRespeitados = await focusService.getRespectedPeriods();
      final earned = await focusService.getEarnedInsignias();

      for (final entry in _focusMilestones.entries) {
        // CORREÇÃO: Pular se já tem a insígnia ou se não atingiu o marco ainda
        if (entry.key > periodosRespeitados) continue;
        if (earned.contains(entry.value)) continue;
        
        await _grantInsigniaSilently(entry.value, focusService);
      }
    } finally {
      _isReconcilingFocusInsignias = false;
    }
  }

  // Métodos processAdultContentEvent e processDietEvent movidos para módulos específicos
  // Verificar: adult_content_gamification_events.dart e diet_gamification_events.dart

  Future<void> _sendInsigniaNotification(
      FocusInsignia insignia,
      String moduleName,
  ) async {
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
            showsUserInterface: true, cancelNotification: false),
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

  Future<void> _sendMedalNotificationWithActions(
      NicheId nicheId,
      GamificationMedal medal,
  ) async {
    final title = 'Nova Medalha Conquistada! 🏆';
    final body =
        'Parabéns! Você alcançou a medalha de ${medal.nameBr} no módulo ${NicheRepository.getById(nicheId).name}.';

    AndroidBitmap<Uint8List>? largeIcon;
    try {
      final ByteData data = await rootBundle.load(medal.asset);
      largeIcon = ByteArrayAndroidBitmap(data.buffer.asUint8List());
    } catch (_) {}

    final androidDetails = AndroidNotificationDetails(
        'disciplinum_medals',
        'Conquistas e Medalhas',
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
}
