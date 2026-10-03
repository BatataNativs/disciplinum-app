import 'package:uuid/uuid.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço de Analytics Local para o Disciplinum
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;
  
  final Uuid _uuid = const Uuid();
  String? _sessionId;
  String? _currentUserId = 'local_user';
  
  AnalyticsService._internal() {
    generateNewSessionId();
  }

  /// Gera um novo ID de sessão para analytics
  void generateNewSessionId() {
    _sessionId = _uuid.v4();
    LoggerService.instance.analytics('Session started', {'session_id': _sessionId});
  }

  /// ID da sessão atual
  String? get sessionId => _sessionId;

  /// Define o usuário atual para analytics
  void setCurrentUser(String? userId) {
    _currentUserId = userId ?? 'local_user';
    LoggerService.instance.analytics('User set for analytics', {'user_id': _currentUserId});
  }

  /// Dispose do serviço de analytics
  void dispose() {
    LoggerService.instance.analytics('Analytics service disposed', {});
  }

  /// Rastreia evento de comportamento do usuário localmente
  Future<void> trackBehaviorEvent({
    required String eventType,
    int? moduleNicheId,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return;

      LoggerService.instance.analytics(eventType, {
        'module_id': moduleNicheId,
        'event_data': eventData,
        'session_id': _sessionId,
      });
    } catch (e) {
      LoggerService.instance.e('Failed to track behavior event', 
         error: e, stackTrace: StackTrace.current);
    }
  }

  /// Rastreia conclusão de hábito/check-in
  Future<void> trackHabitCompleted({
    required int nicheId,
    required String habitType,
    Map<String, dynamic>? metadata,
  }) async {
    await trackBehaviorEvent(
      eventType: 'habit_completed',
      moduleNicheId: nicheId,
      eventData: {
        'habit_type': habitType,
        ...?metadata,
      },
    );
  }

  /// Rastreia recaída (relapse)
  Future<void> trackRelapse({
    required int nicheId,
    required String reason,
    Map<String, dynamic>? context,
  }) async {
    await trackBehaviorEvent(
      eventType: 'relapse',
      moduleNicheId: nicheId,
      eventData: {
        'reason': reason,
        ...?context,
      },
    );
  }

  /// Rastreia sessão de foco completada
  Future<void> trackFocusCompleted({
    required int nicheId,
    required int durationMinutes,
    required int interruptions,
    Map<String, dynamic>? metadata,
  }) async {
    await trackBehaviorEvent(
      eventType: 'focus_completed',
      moduleNicheId: nicheId,
      eventData: {
        'duration_minutes': durationMinutes,
        'interruptions': interruptions,
        ...?metadata,
      },
    );
  }

  /// Rastreia quando um módulo é iniciado
  Future<void> trackModuleStarted({
    required int nicheId,
    String? source, // 'home', 'notification', 'deeplink'
  }) async {
    await trackBehaviorEvent(
      eventType: 'module_started',
      moduleNicheId: nicheId,
      eventData: {
        'source': source ?? 'unknown',
      },
    );
  }

  /// Rastreia conquistas/gamification
  Future<void> trackAchievement({
    required int nicheId,
    required String achievementType,
    required String achievementName,
    Map<String, dynamic>? achievementData,
  }) async {
    await trackBehaviorEvent(
      eventType: 'achievement_earned',
      moduleNicheId: nicheId,
      eventData: {
        'achievement_type': achievementType,
        'achievement_name': achievementName,
        ...?achievementData,
      },
    );
  }

  /// Rastreia bloqueio de app
  Future<void> trackAppBlocked({
    required String packageName,
    required String blockingReason,
    String? ruleName,
  }) async {
    await trackBehaviorEvent(
      eventType: 'app_blocked',
      eventData: {
        'package_name': packageName,
        'blocking_reason': blockingReason,
        'rule_name': ruleName,
      },
    );
  }

  /// Rastreia engajamento do usuário
  Future<void> trackEngagement({
    required String action, // 'open_app', 'daily_active', 'feature_used'
    Map<String, dynamic>? context,
  }) async {
    await trackBehaviorEvent(
      eventType: 'user_engagement',
      eventData: {
        'action': action,
        ...?context,
      },
    );
  }

  /// Rastreia eventos de monetização
  Future<void> trackMonetization({
    required String eventType, // 'ad_viewed', 'iap_attempt', 'purchase_completed'
    Map<String, dynamic>? transactionData,
  }) async {
    await trackBehaviorEvent(
      eventType: eventType,
      eventData: transactionData,
    );
  }

  /// Rastreia performance do app
  Future<void> trackPerformance({
    required String operation,
    required int durationMs,
    Map<String, dynamic>? metrics,
  }) async {
    await trackBehaviorEvent(
      eventType: 'performance_metric',
      eventData: {
        'operation': operation,
        'duration_ms': durationMs,
        ...?metrics,
      },
    );
  }

  /// Rastreia erros do app
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    await trackBehaviorEvent(
      eventType: 'app_error',
      eventData: {
        'error_type': errorType,
        'error_message': errorMessage,
        'stack_trace': stackTrace,
        ...?context,
      },
    );
  }

  /// Obtém estatísticas do usuário
  Future<Map<String, dynamic>> getUserStats() async {
    return {
      'total_events': 0,
      'today_events': 0,
      'session_id': _sessionId,
    };
  }

  /// Limpa eventos antigos (manutenção)
  Future<void> cleanupOldEvents({int daysToKeep = 90}) async {
    LoggerService.instance.i('Local analytics maintenance completed');
  }

  /// Retorna usuário atual
  String? _getCurrentUserId() {
    return _currentUserId;
  }
}
