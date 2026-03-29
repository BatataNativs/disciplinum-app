import 'dart:convert';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/isar_preferences_repository.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_model.dart';

/// Serviço principal para gerenciamento de dieta - VERSÃO RIVERPOD
/// Service puro sem ChangeNotifier - estado gerenciado pelo controller
class DietService {
  static const String _goalsKey = 'diet_goals';
  static const String _mealsKey = 'diet_meals';
  static const String _summaryKey = 'diet_summary';

  final IsarPreferencesRepository _prefs;

  DailyNutritionGoals? _goals;
  List<MealRecord> _meals = [];
  DailyNutritionSummary? _summary;

  DietService(this._prefs) {
    _loadGoals();
    _loadMeals();
    _calculateSummary();
  }

  // GETTERS
  DailyNutritionGoals get goals => _goals ?? DailyNutritionGoals(
        calories: 2000,
        proteins: 150.0,
        carbs: 250.0,
        fats: 65.0,
        fibers: 25.0,
        water: 2000,
      );

  List<MealRecord> get meals => List.unmodifiable(_meals);

  DailyNutritionSummary get summary {
    if (_summary == null) {
      _calculateSummary();
    }
    return _summary!;
  }

  // MÉTODOS DE AÇÃO
  Future<void> updateGoals(DailyNutritionGoals newGoals) async {
    _goals = newGoals;
    await _saveGoals();
    _calculateSummary();
  }

  Future<void> addMeal(MealRecord meal) async {
    _meals.add(meal);
    await _saveMeals();
    _calculateSummary();
  }

  Future<void> updateMeal(MealRecord updatedMeal) async {
    final index = _meals.indexWhere((m) => m.id == updatedMeal.id);
    if (index != -1) {
      _meals[index] = updatedMeal;
      await _saveMeals();
      _calculateSummary();
    }
  }

  Future<void> deleteMeal(String mealId) async {
    _meals.removeWhere((m) => m.id == mealId);
    await _saveMeals();
    _calculateSummary();
  }

  Future<void> logWater(int amount) async {
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    
    // Adiciona água ao resumo do dia
    if (_summary != null && _dateKey(_summary!.date) == todayKey) {
      final updatedSummary = _summary!.copyWith(
        totalWater: _summary!.totalWater + amount,
      );
      _summary = updatedSummary;
      await _saveSummary();
    }
  }

  Future<void> resetDailyProgress() async {
    final today = DateTime.now();
    final todayKey = _dateKey(today);
    
    // Remove refeições do dia atual
    _meals.removeWhere((meal) => _dateKey(meal.date) == todayKey);
    await _saveMeals();
    
    // Reseta o resumo do dia
    _summary = null;
    await _saveSummary();
  }

  // MÉTODOS PRIVADOS
  Future<void> _loadGoals() async {
    try {
      final String? data = await _prefs.getString(_goalsKey);
      if (data != null) {
        final json = jsonDecode(data);
        _goals = DailyNutritionGoals.fromJson(json);
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar metas da dieta: $e');
    }
  }

  Future<void> _loadMeals() async {
    try {
      final String? data = await _prefs.getString(_mealsKey);
      if (data != null) {
        final List<dynamic> json = jsonDecode(data);
        _meals = json.map((meal) => MealRecord.fromJson(meal)).toList();
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar refeições: $e');
    }
  }

  Future<void> _saveGoals() async {
    try {
      if (_goals != null) {
        await _prefs.setString(_goalsKey, jsonEncode(_goals!.toJson()));
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar metas da dieta: $e');
    }
  }

  Future<void> _saveMeals() async {
    try {
      await _prefs.setString(_mealsKey, jsonEncode(_meals.map((m) => m.toJson()).toList()));
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar refeições: $e');
    }
  }

  Future<void> _saveSummary() async {
    try {
      if (_summary != null) {
        await _prefs.setString(_summaryKey, jsonEncode(_summary!.toJson()));
      }
    } catch (e) {
      LoggerService.instance.e('Erro ao salvar resumo: $e');
    }
  }

  void _calculateSummary() {
    final today = DateTime.now();
    final todayMeals = _meals.where((meal) => 
        meal.date.year == today.year &&
        meal.date.month == today.month &&
        meal.date.day == today.day
    ).toList();

    final totalCalories = todayMeals.fold<int>(0, (sum, meal) => sum + meal.calories);
    final totalProteins = todayMeals.fold<double>(0.0, (sum, meal) => sum + meal.proteins);
    final totalCarbs = todayMeals.fold<double>(0.0, (sum, meal) => sum + meal.carbs);
    final totalFats = todayMeals.fold<double>(0.0, (sum, meal) => sum + meal.fats);
    final totalFibers = todayMeals.fold<double>(0.0, (sum, meal) => sum + meal.fibers);
    final totalWater = todayMeals.fold<int>(0, (sum, meal) => sum + meal.water);

    final goalsMet = totalCalories >= goals.calories &&
                   totalProteins >= goals.proteins &&
                   totalCarbs >= goals.carbs &&
                   totalFats >= goals.fats &&
                   totalFibers >= goals.fibers &&
                   totalWater >= goals.water;

    _summary = DailyNutritionSummary(
      date: today,
      goals: goals,
      meals: todayMeals,
      totalCalories: totalCalories,
      totalProteins: totalProteins,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
      totalFibers: totalFibers,
      totalWater: totalWater,
      goalsMet: goalsMet,
    );
  }

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
