import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/spending/gamification/presentation/controllers/spending_gamification_controller.dart';

/// Serviço local de eventos de gamificação para o módulo Spending
/// Substitui o processSpendingEvent do GamificationAwardEngine central
class SpendingGamificationEvents {
  final SpendingGamificationController _controller;

  SpendingGamificationEvents(this._controller);

  /// Processa eventos do módulo Spending localmente
  Future<void> processSpendingEvent(String eventType) async {
    switch (eventType) {
      case 'expense_added':
        LoggerService.instance.gamification('Despesa adicionada ao controle');
        // Usar método existente para processar sucesso
        await _controller.performSuccessfulMonth();
        break;
        
      case 'daily_goal_met':
        LoggerService.instance.gamification('Meta diária de controle atingida');
        await _controller.performSuccessfulMonth();
        break;
        
      case 'streak_extended':
        LoggerService.instance.gamification('Streak de controle estendido');
        await _controller.performSuccessfulMonth();
        break;
        
      case 'budget_achieved':
        LoggerService.instance.gamification('Orçamento mensal alcançado');
        await _controller.performSuccessfulMonth();
        break;
        
      case 'month_failed':
        LoggerService.instance.gamification('Mês com contas em atraso');
        await _controller.performFailedMonth();
        break;
        
      default:
        LoggerService.instance.w('Evento Spending desconhecido: $eventType');
    }
  }

  /// Concede medalha localmente
  Future<void> awardMedal(String medalName) async {
    LoggerService.instance.gamification('Medalha Spending concedida: $medalName');
    // Por enquanto, apenas log - implementação futura pode adicionar ao estado
    await _controller.performSuccessfulMonth();
  }

  /// Concede insígnia localmente
  Future<void> awardInsignia(String insigniaName) async {
    LoggerService.instance.gamification('Insígnia Spending concedida: $insigniaName');
    // Por enquanto, apenas log - implementação futura pode adicionar ao estado
    await _controller.performSuccessfulMonth();
  }
}
