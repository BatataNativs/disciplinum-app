import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço local de eventos de gamificação para o módulo Smoking
/// Substitui o processSmokingEvent do GamificationAwardEngine central
class SmokingGamificationEvents {
  
  /// Processa eventos do módulo Smoking localmente
  Future<void> processSmokingEvent(String eventType) async {
    switch (eventType) {
      case 'quit_day':
        LoggerService.instance.gamification('Dia sem fumar registrado');
        break;
        
      case 'milestone_reached':
        LoggerService.instance.gamification('Marco de abstinência alcançado');
        break;
        
      case 'relapse':
        LoggerService.instance.gamification('Recaída registrada - reiniciando progresso');
        break;
        
      default:
        LoggerService.instance.w('Evento Smoking desconhecido: $eventType');
    }
  }

  /// Concede medalha localmente
  Future<void> awardMedal(String medalName) async {
    LoggerService.instance.gamification('Medalha Smoking concedida: $medalName');
  }

  /// Concede insígnia localmente
  Future<void> awardInsignia(String insigniaName) async {
    LoggerService.instance.gamification('Insígnia Smoking concedida: $insigniaName');
  }
}
