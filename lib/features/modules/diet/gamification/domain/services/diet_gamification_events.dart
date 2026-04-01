import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/diet/domain/services/diet_service.dart';

/// Eventos de gamificação específicos do módulo Diet
/// 100% independente e local ao módulo
class DietGamificationEvents {
  
  /// Eventos específicos do módulo Diet
  static const String goalCompleted = 'diet_goal_completed';
  static const String mealCompleted = 'diet_meal_completed';
  static const String streakExtended = 'diet_streak_extended';
  static const String nutritionGoal = 'diet_nutrition_goal';

  /// Processa eventos do módulo Diet
  Future<void> processDietEvent(String eventType, DietService service) async {
    switch (eventType) {
      case goalCompleted:
        LoggerService.instance.gamification('Meta de dieta completada');
        await _updateDietStats(service, 'goal_completed');
        break;
      case mealCompleted:
        LoggerService.instance.gamification('Refeição completada');
        await _updateDietStats(service, 'meal_completed');
        break;
      case streakExtended:
        LoggerService.instance.gamification('Streak de dieta extendido');
        await _updateDietStats(service, 'streak_extended');
        break;
      case nutritionGoal:
        LoggerService.instance.gamification('Meta nutricional atingida');
        await _updateDietStats(service, 'nutrition_goal');
        break;
    }
  }

  /// Atualiza estatísticas do Diet Service
  Future<void> _updateDietStats(DietService service, String action) async {
    try {
      final summary = service.summary;
      LoggerService.instance.gamification('Diet estatísticas atualizadas para ação: $action');
      
      // Log do completion rate para analytics
      if (summary.goalsMet == true) {
        LoggerService.instance.gamification('Metas atingidas: ${summary.goalsMet}');
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao atualizar estatísticas do diet: $e');
    }
  }
}
