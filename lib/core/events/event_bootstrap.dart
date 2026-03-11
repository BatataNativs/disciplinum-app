import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      // Tentar atualizar a sessão se existir, mas não falhar se não houver
      try {
        await Supabase.instance.client.auth.refreshSession();
      } catch (e) {
        // Ignorar erro de sessão ausente durante a inicialização
        LoggerService.instance
            .d('EventBootstrap: Nenhuma sessão ativa para atualizar');
      }

      // Configurar usuário atual nos serviços de eventos
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        AnalyticsService.instance.setCurrentUser(user.id);
        GamificationEventEmitter.setCurrentUser(user.id);

        // Gerar nova sessão para analytics
        AnalyticsService.instance.generateNewSessionId();
        GamificationEventEmitter.setCurrentSession(
            AnalyticsService.instance.sessionId);

        LoggerService.instance.system(
            'EventBootstrap: Event system initialized for user ${user.id}');
      } else {
        // Usuário anônimo - gerar sessão temporária
        AnalyticsService.instance.generateNewSessionId();
        GamificationEventEmitter.setCurrentSession(
            AnalyticsService.instance.sessionId);

        LoggerService.instance.system(
            'EventBootstrap: Event system initialized for anonymous user');
      }

      _isInitialized = true;
    } catch (e) {
      LoggerService.instance
          .e('EventBootstrap: Error initializing event system: $e');
      // Não falhar completamente se eventos não inicializarem
    }
  }

  /// Atualiza o usuário atual nos serviços de eventos
  /// Chamado após login/logout
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

  /// Limpa os serviços de eventos (chamado no logout)
  static void dispose() {
    AnalyticsService.instance.dispose();
    _isInitialized = false;

    LoggerService.instance.system('EventBootstrap: Event system disposed');
  }
}
