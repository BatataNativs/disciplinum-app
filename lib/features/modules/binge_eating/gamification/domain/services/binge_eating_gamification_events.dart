import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/services/binge_eating_service.dart';

/// Eventos de gamificação específicos do módulo BingeEating
/// 100% independente e local ao módulo
class BingeEatingGamificationEvents {
  
  /// Processa eventos do módulo BingeEating
  Future<void> processBingeEatingEvent(String eventType, BingeEatingService service) async {
    switch (eventType) {
      case 'resisted_craving':
        LoggerService.instance.gamification('Desejo resistido com sucesso');
        await _updateBingeEatingStats(service, 'resisted');
        break;
      case 'recovery_milestone':
        LoggerService.instance.gamification('Marco de recuperação alcançado');
        await _checkBingeEatingMilestones(service);
        break;
      default:
        LoggerService.instance.gamification('Evento binge eating desconhecido: $eventType');
    }
  }

  /// Atualiza estatísticas do BingeEating
  Future<void> _updateBingeEatingStats(BingeEatingService service, String action) async {
    // Implementação específica do módulo
    final stats = service.getStatistics();
    LoggerService.instance.gamification('Stats BingeEating atualizadas: $action - Total: $stats');
  }

  /// Verifica marcos de recuperação do BingeEating
  Future<void> _checkBingeEatingMilestones(BingeEatingService service) async {
    // Implementação específica do módulo
    final stats = service.getStatistics();
    final recoveryDays = stats['daysSinceLastEpisode'] ?? 0;
    LoggerService.instance.gamification('Verificando marcos de recuperação: $recoveryDays dias');
    
    // Lógica de marcos específica do módulo
    if (recoveryDays >= 7) {
      LoggerService.instance.gamification('Marco: 1 semana de recuperação! 🎉');
    }
    if (recoveryDays >= 30) {
      LoggerService.instance.gamification('Marco: 1 mês de recuperação! 🏆');
    }
    if (recoveryDays >= 90) {
      LoggerService.instance.gamification('Marco: 3 meses de recuperação! 💎');
    }
  }
}
