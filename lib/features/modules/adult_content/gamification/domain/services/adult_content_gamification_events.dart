import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service.dart';

/// Eventos de gamificação específicos do módulo Adult Content
/// 100% independente e local ao módulo
class AdultContentGamificationEvents {
  
  /// Eventos específicos do módulo Adult Content
  static const String blocked = 'adult_content_blocked';
  static const String accessed = 'adult_content_accessed';
  static const String limitReached = 'adult_content_limit_reached';
  static const String streakExtended = 'adult_content_streak_extended';

  /// Processa eventos do módulo Adult Content
  Future<void> processAdultContentEvent(String eventType, AdultContentService service) async {
    switch (eventType) {
      case blocked:
        LoggerService.instance.gamification('Adult Content bloqueado');
        await _updateAdultContentStats(service, 'blocked');
        break;
      case accessed:
        LoggerService.instance.gamification('Adult Content acessado');
        await _updateAdultContentStats(service, 'accessed');
        break;
      case limitReached:
        LoggerService.instance.gamification('Limite diário atingido');
        await _updateAdultContentStats(service, 'limit_reached');
        break;
      case streakExtended:
        LoggerService.instance.gamification('Streak extendido');
        await _updateAdultContentStats(service, 'streak_extended');
        break;
    }
  }

  /// Atualiza estatísticas do Adult Content
  Future<void> _updateAdultContentStats(AdultContentService service, String action) async {
    final currentStats = service.stats;
    
    // Criar novas estatísticas baseadas na ação
    final newStats = AdultContentStats(
      totalBlockedAttempts: currentStats.totalBlockedAttempts + (action == 'blocked' ? 1 : 0),
      totalAccessAttempts: currentStats.totalAccessAttempts + ((action == 'accessed' || action == 'limit_reached') ? 1 : 0),
      totalAccessTime: currentStats.totalAccessTime,
    );

    LoggerService.instance.gamification('Adult Content estatísticas atualizadas para ação: $action');
    
    // Atualizar estatísticas no serviço
    await service.updateStats(newStats);
    
    // Usar a variável para evitar warning
    LoggerService.instance.gamification('Estatísticas atualizadas: ${newStats.totalBlockedAttempts} bloqueios, ${newStats.totalAccessAttempts} acessos');
  }
}
