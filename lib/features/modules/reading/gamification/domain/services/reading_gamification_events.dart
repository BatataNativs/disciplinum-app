import 'package:disciplinum/core/logging/logger_service.dart';

/// Serviço local de eventos de gamificação para o módulo Reading
/// Substitui o processReadingEvent do GamificationAwardEngine central
class ReadingGamificationEvents {
  
  /// Processa eventos do módulo Reading localmente
  Future<void> processReadingEvent(String eventType) async {
    switch (eventType) {
      case 'daily_goal_completed':
        LoggerService.instance.gamification('Meta diária de leitura alcançada');
        break;
        
      case 'book_completed':
        LoggerService.instance.gamification('Livro concluído');
        break;
        
      case 'reading_streak':
        LoggerService.instance.gamification('Streak de leitura estendido');
        break;
        
      default:
        LoggerService.instance.w('Evento Reading desconhecido: $eventType');
    }
  }

  /// Concede medalha localmente
  Future<void> awardMedal(String medalName) async {
    LoggerService.instance.gamification('Medalha Reading concedida: $medalName');
  }

  /// Concede insígnia localmente
  Future<void> awardInsignia(String insigniaName) async {
    LoggerService.instance.gamification('Insígnia Reading concedida: $insigniaName');
  }
}
