import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/core/events/events/gamification_events.dart';
import 'package:disciplinum/core/events/events/behavior_events.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

/// Helper para emitir eventos de gamificação de forma padronizada
/// Centraliza a lógica de emissão de eventos para evitar duplicação
class GamificationEventEmitter {
  static final EventBus _eventBus = EventBus.instance;
  static String? _currentUserId;
  static String? _currentSessionId;

  /// Define o usuário atual para todos os eventos
  static void setCurrentUser(String? userId) {
    _currentUserId = userId;
  }

  /// Define a sessão atual para todos os eventos
  static void setCurrentSession(String? sessionId) {
    _currentSessionId = sessionId;
  }

  /// Emite evento quando uma medalha é conquistada
  /// Usa [Map] com dados da medalha (fragmentação por módulo)

  /// Emite evento quando um módulo é ativado
  static void emitModuleActivated({
    required NicheId nicheId,
    Map<String, dynamic>? settings,
  }) {
    final event = ModuleActivatedEvent(
      nicheId: nicheId,
      userId: _currentUserId,
      activationDate: DateTime.now(),
      settings: settings,
      sessionId: _currentSessionId,
    );
    
    _eventBus.emit(event);
    
    LoggerService.instance.gamification('Module activated', data: {'module': nicheId});
  }

  /// Emite evento quando um módulo é desativado
  static void emitModuleDeactivated({
    required NicheId nicheId,
    String? reason,
  }) {
    final event = ModuleDeactivatedEvent(
      nicheId: nicheId,
      userId: _currentUserId,
      deactivationDate: DateTime.now(),
      reason: reason,
      sessionId: _currentSessionId,
    );
    
    _eventBus.emit(event);
    
    LoggerService.instance.gamification('Module deactivated', data: {'module': nicheId, 'reason': reason});
  }

  /// Emite evento quando a streak é atualizada
  static void emitStreakUpdated({
    required NicheId nicheId,
    required int previousStreak,
    required int newStreak,
    bool isRecord = false,
  }) {
    final event = StreakUpdatedEvent(
      nicheId: nicheId,
      previousStreak: previousStreak,
      newStreak: newStreak,
      userId: _currentUserId,
      isRecord: isRecord,
      sessionId: _currentSessionId,
    );
    
    _eventBus.emit(event);
    
    LoggerService.instance.gamification('Streak updated', data: {'module': nicheId, 'from': previousStreak, 'to': newStreak});
  }

  /// Emite evento quando uma insígnia de foco é conquistada
  /// Usa [Map] com dados da insígnia (fragmentação por módulo)

  /// Emite evento quando um período de foco é completado
  static void emitFocusPeriodCompleted({
    required NicheId nicheId,
    required Duration focusDuration,
    required int completedSessions,
    required bool wasProductive,
  }) {
    final event = FocusPeriodCompletedEvent(
      nicheId: nicheId,
      focusDuration: focusDuration,
      completedSessions: completedSessions,
      wasProductive: wasProductive,
      userId: _currentUserId,
      sessionId: _currentSessionId,
    );
    
    _eventBus.emit(event);
    
    LoggerService.instance.gamification('Focus period completed', data: {'module': nicheId});
  }

  /// Emite evento quando uma conquista genérica é desbloqueada
  static void emitAchievementUnlocked({
    required NicheId nicheId,
    required String achievementId,
    required String achievementName,
    required String description,
    required int pointsAwarded,
  }) {
    final event = AchievementUnlockedEvent(
      nicheId: nicheId,
      achievementId: achievementId,
      achievementName: achievementName,
      description: description,
      pointsAwarded: pointsAwarded,
      userId: _currentUserId,
      sessionId: _currentSessionId,
    );
    
    _eventBus.emit(event);
    
    LoggerService.instance.gamification('Achievement unlocked', data: {'achievement': achievementName});
  }

  /// Emite evento de check-in
  static void emitCheckIn({
    required NicheId nicheId,
    required CheckInType type,
    Map<String, dynamic>? additionalData,
  }) {
    final event = CheckInEvent(
      nicheId: nicheId,
      userId: _currentUserId,
      type: type,
      additionalData: additionalData,
      sessionId: _currentSessionId,
    );
    
    _eventBus.emit(event);
    
    LoggerService.instance.gamification('Check-in', data: {'type': type, 'module': nicheId});
  }

  /// Emite evento de recaída
  static void emitRelapse({
    required NicheId nicheId,
    required RelapseType type,
    String? reason,
    required int streakLost,
    Map<String, dynamic>? context,
  }) {
    final event = RelapseEvent(
      nicheId: nicheId,
      userId: _currentUserId,
      type: type,
      reason: reason,
      streakLost: streakLost,
      context: context,
      sessionId: _currentSessionId,
    );
    
    _eventBus.emit(event);
    
    LoggerService.instance.gamification('Relapse', data: {'type': type, 'module': nicheId, 'streakLost': streakLost});
  }

  /// Emite evento quando sessão de foco começa
  static void emitFocusSessionStarted({
    required NicheId nicheId,
    required List<String> blockedApps,
    required Duration plannedDuration,
    Map<String, dynamic>? settings,
  }) {
    final event = FocusSessionStartedEvent(
      nicheId: nicheId,
      userId: _currentUserId,
      blockedApps: blockedApps,
      plannedDuration: plannedDuration,
      settings: settings,
      sessionId: _currentSessionId,
    );
    
    _eventBus.emit(event);
    
    LoggerService.instance.gamification('Focus session started', data: {'module': nicheId});
  }

  /// Emite evento quando sessão de foco termina
  static void emitFocusSessionCompleted({
    required NicheId nicheId,
    required Duration actualDuration,
    required int interruptionsCount,
    required bool wasSuccessful,
    required List<String> triggeredBlocks,
  }) {
    final event = FocusSessionCompletedEvent(
      nicheId: nicheId,
      userId: _currentUserId,
      actualDuration: actualDuration,
      interruptionsCount: interruptionsCount,
      wasSuccessful: wasSuccessful,
      triggeredBlocks: triggeredBlocks,
      sessionId: _currentSessionId,
    );
    
    _eventBus.emit(event);
    
    LoggerService.instance.gamification('Focus session completed', data: {'module': nicheId, 'success': wasSuccessful});
  }

  /// Emite evento quando um app é bloqueado
  static void emitAppBlocked({
    required String packageName,
    required String appName,
    required String blockingReason,
    NicheId? relatedNiche,
  }) {
    final event = AppBlockedEvent(
      packageName: packageName,
      appName: appName,
      userId: _currentUserId,
      blockingReason: blockingReason,
      relatedNiche: relatedNiche,
      sessionId: _currentSessionId,
    );
    
    _eventBus.emit(event);
    
    LoggerService.instance.gamification('App blocked', data: {'app': appName, 'package': packageName});
  }

  /// Emite evento de interação com módulo
  static void emitModuleInteraction({
    required NicheId nicheId,
    required String interactionType,
    Map<String, dynamic>? interactionData,
  }) {
    final event = ModuleInteractionEvent(
      nicheId: nicheId,
      userId: _currentUserId,
      interactionType: interactionType,
      interactionData: interactionData,
      interactionTime: DateTime.now(),
      sessionId: _currentSessionId,
    );
    
    _eventBus.emit(event);
    
    LoggerService.instance.gamification('Module interaction', data: {'type': interactionType, 'module': nicheId});
  }
}
