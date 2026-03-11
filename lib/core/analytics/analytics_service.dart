import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço de Analytics para o Disciplinum
/// Usa a tabela user_behavior_events do Supabase
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;
  
  final SupabaseClient _supabase = Supabase.instance.client;
  final Uuid _uuid = const Uuid();
  String? _sessionId;
  
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
    LoggerService.instance.analytics('User set for analytics', {'user_id': userId});
  }

  /// Dispose do serviço de analytics
  void dispose() {
    LoggerService.instance.analytics('Analytics service disposed', {});
  }

  /// Rastreia evento de comportamento do usuário
  Future<void> trackBehaviorEvent({
    required String eventType,
    int? moduleNicheId,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return;

      final data = {
        'user_id': userId,
        'event_type': eventType,
        'module_niche_id': moduleNicheId,
        'event_data': eventData ?? {},
        'session_id': _sessionId,
      };

      await _supabase
          .from('user_behavior_events')
          .insert(data);

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
    try {
      final userId = _getCurrentUserId();
      if (userId == null) return {};

      final response = await _supabase
          .from('user_behavior_events')
          .select('event_type, created_at')
          .eq('user_id', userId);

      // Calcular estatísticas básicas
      final totalEvents = response.length;
      final today = DateTime.now();
      final todayEvents = response.where((event) {
        final createdAt = DateTime.parse(event['created_at']);
        return createdAt.year == today.year && 
               createdAt.month == today.month && 
               createdAt.day == today.day;
      }).length;

      return {
        'total_events': totalEvents,
        'today_events': todayEvents,
        'session_id': _sessionId,
      };
    } catch (e) {
      LoggerService.instance.e('Failed to get user stats', error: e);
      return {};
    }
  }

  /// Limpa eventos antigos (manutenção)
  Future<void> cleanupOldEvents({int daysToKeep = 90}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
      
      await _supabase
          .from('user_behavior_events')
          .delete()
          .lt('created_at', cutoffDate.toIso8601String());

      LoggerService.instance.i('Cleaned up analytics events older than $daysToKeep days');
    } catch (e) {
      LoggerService.instance.e('Failed to cleanup old events', error: e);
    }
  }

  /// Verifica se usuário está autenticado
  String? _getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }
}
