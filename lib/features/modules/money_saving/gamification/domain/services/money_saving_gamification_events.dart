import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço local de eventos de gamificação para o módulo Money Saving
/// Substitui o processMoneySavingEvent do GamificationAwardEngine central
class MoneySavingGamificationEvents {
  
  /// Processa eventos do módulo Money Saving localmente
  Future<void> processMoneySavingEvent(String eventType) async {
    switch (eventType) {
      case 'daily_goal_completed':
        LoggerService.instance.gamification('Meta diária de economia alcançada');
        break;
        
      case 'weekly_goal_achieved':
        LoggerService.instance.gamification('Meta semanal de economia alcançada');
        break;
        
      case 'milestone_reached':
        LoggerService.instance.gamification('Marco de economia alcançado');
        break;
        
      default:
        LoggerService.instance.w('Evento MoneySaving desconhecido: $eventType');
    }
  }

  /// Concede medalha localmente
  Future<void> awardMedal(String medalName) async {
    LoggerService.instance.gamification('Medalha MoneySaving concedida: $medalName');
  }

  /// Concede insígnia localmente
  Future<void> awardInsignia(String insigniaName) async {
    LoggerService.instance.gamification('Insígnia MoneySaving concedida: $insigniaName');
  }
}
