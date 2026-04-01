import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço local de eventos de gamificação para o módulo Procrastination
/// Substitui o processProcrastinationEvent do GamificationAwardEngine central
class ProcrastinationGamificationEvents {
  
  /// Processa eventos do módulo Procrastination localmente
  Future<void> processProcrastinationEvent(String eventType) async {
    switch (eventType) {
      case 'focus_session_completed':
        LoggerService.instance.gamification('Sessão de foco concluída');
        break;
        
      case 'daily_goal_achieved':
        LoggerService.instance.gamification('Meta diária de produtividade alcançada');
        break;
        
      case 'distraction_blocked':
        LoggerService.instance.gamification('Distração bloqueada com sucesso');
        break;
        
      default:
        LoggerService.instance.w('Evento Procrastination desconhecido: $eventType');
    }
  }

  /// Concede medalha localmente
  Future<void> awardMedal(String medalName) async {
    LoggerService.instance.gamification('Medalha Procrastination concedida: $medalName');
  }

  /// Concede insígnia localmente
  Future<void> awardInsignia(String insigniaName) async {
    LoggerService.instance.gamification('Insígnia Procrastination concedida: $insigniaName');
  }
}
