import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço local de eventos de gamificação para o módulo Focus
/// Substitui o processFocusEvent do GamificationAwardEngine central
class FocusGamificationEvents {
  
  /// Processa eventos do módulo Focus localmente
  Future<void> processFocusEvent(String eventType) async {
    switch (eventType) {
      case 'focus_session_completed':
        LoggerService.instance.gamification('Sessão de foco concluída');
        break;
        
      case 'daily_goal_achieved':
        LoggerService.instance.gamification('Meta diária de foco alcançada');
        break;
        
      case 'distraction_blocked':
        LoggerService.instance.gamification('Distração bloqueada com sucesso');
        break;
        
      default:
        LoggerService.instance.w('Evento Focus desconhecido: $eventType');
    }
  }

  /// Concede medalha localmente
  Future<void> awardMedal(String medalName) async {
    LoggerService.instance.gamification('Medalha Focus concedida: $medalName');
  }

  /// Concede insígnia localmente
  Future<void> awardInsignia(String insigniaName) async {
    LoggerService.instance.gamification('Insígnia Focus concedida: $insigniaName');
  }
}
