import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/analytics/analytics_service.dart';
import 'package:disciplinum/core/events/events/gamification_event_emitter.dart';

/// Bootstrap para inicialização do sistema de eventos
/// Configura analytics e emissores de eventos quando o app inicia
class EventBootstrap {
  static bool _isInitialized = false;

  /// Inicializa todos os serviços de eventos
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const defaultUserId = 'local_user';
      AnalyticsService.instance.setCurrentUser(defaultUserId);
      GamificationEventEmitter.setCurrentUser(defaultUserId);

      // Gerar nova sessão para analytics
      AnalyticsService.instance.generateNewSessionId();
      GamificationEventEmitter.setCurrentSession(
          AnalyticsService.instance.sessionId);

      LoggerService.instance.system(
          'EventBootstrap: Event system initialized locally');

      _isInitialized = true;
    } catch (e) {
      LoggerService.instance
          .e('EventBootstrap: Error initializing event system: $e');
    }
  }

  /// Atualiza o usuário atual nos serviços de eventos
  static Future<void> updateUser(String? userId) async {
    AnalyticsService.instance.setCurrentUser(userId);
    GamificationEventEmitter.setCurrentUser(userId);

    // Gerar nova sessão quando usuário muda
    AnalyticsService.instance.generateNewSessionId();
    GamificationEventEmitter.setCurrentSession(
        AnalyticsService.instance.sessionId);

    LoggerService.instance.system(
        'EventBootstrap: User updated to $userId with session ${AnalyticsService.instance.sessionId}');
  }

  /// Limpa os serviços de eventos
  static void dispose() {
    AnalyticsService.instance.dispose();
    _isInitialized = false;

    LoggerService.instance.system('EventBootstrap: Event system disposed');
  }
}
