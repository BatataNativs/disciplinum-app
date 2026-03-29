import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/diet/domain/services/diet_service.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_model.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Controller Riverpod para Diet
/// Substitui ChangeNotifier por StateNotifier
class DietController extends StateNotifier<DietState> {
  final DietService _service;
  
  DietController(this._service) : super(const DietState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final goals = _service.goals;
      final meals = _service.meals;
      final summary = _service.summary;
      
      state = state.copyWith(
        goals: goals,
        meals: meals,
        summary: summary,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateGoals(DailyNutritionGoals goals) async {
    try {
      await _service.updateGoals(goals);
      state = state.copyWith(goals: goals);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addMeal(MealRecord meal) async {
    try {
      await _service.addMeal(meal);
      await _loadData(); // Recarrega meals e summary
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateMeal(MealRecord meal) async {
    try {
      await _service.updateMeal(meal);
      await _loadData(); // Recarrega meals e summary
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      await _service.deleteMeal(mealId);
      await _loadData(); // Recarrega meals e summary
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> logWater(int glasses) async {
    try {
      await _service.logWater(glasses);
      await _loadData(); // Recarrega summary
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> resetDailyProgress() async {
    try {
      await _service.resetDailyProgress();
      await _loadData(); // Recarrega tudo
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Estado do DietController
class DietState {
  final DailyNutritionGoals? goals;
  final List<MealRecord> meals;
  final DailyNutritionSummary? summary;
  final bool isLoading;
  final String? error;

  const DietState({
    this.goals,
    this.meals = const [],
    this.summary,
    this.isLoading = false,
    this.error,
  });

  DietState copyWith({
    DailyNutritionGoals? goals,
    List<MealRecord>? meals,
    DailyNutritionSummary? summary,
    bool? isLoading,
    String? error,
  }) {
    return DietState(
      goals: goals ?? this.goals,
      meals: meals ?? this.meals,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Calcula estatísticas derivadas
  double get dailyCaloriesConsumed {
    return meals.fold(0.0, (sum, meal) => sum + meal.calories);
  }

  double get dailyProteinConsumed {
    return meals.fold(0.0, (sum, meal) => sum + meal.proteins);
  }

  double get dailyCarbsConsumed {
    return meals.fold(0.0, (sum, meal) => sum + meal.carbs);
  }

  double get dailyFatsConsumed {
    return meals.fold(0.0, (sum, meal) => sum + meal.fats);
  }

  double get caloriesProgress {
    if (goals == null || goals!.calories == 0) return 0.0;
    return (dailyCaloriesConsumed / goals!.calories).clamp(0.0, 1.0);
  }

  double get proteinProgress {
    if (goals == null || goals!.proteins == 0) return 0.0;
    return (dailyProteinConsumed / goals!.proteins).clamp(0.0, 1.0);
  }

  double get carbsProgress {
    if (goals == null || goals!.carbs == 0) return 0.0;
    return (dailyCarbsConsumed / goals!.carbs).clamp(0.0, 1.0);
  }

  double get fatsProgress {
    if (goals == null || goals!.fats == 0) return 0.0;
    return (dailyFatsConsumed / goals!.fats).clamp(0.0, 1.0);
  }
}

/// Provider para o DietController
final dietControllerProvider = StateNotifierProvider<DietController, DietState>((ref) {
  final service = ref.watch(dietServiceProvider);
  return DietController(service);
});
