import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/core/storage/isar_preferences_repository.dart';

/// Metas nutricionais diárias
class DailyNutritionGoals {
  final int calories;
  final double proteins; // em gramas
  final double carbs; // em gramas
  final double fats; // em gramas
  final double fibers; // em gramas
  final int water; // em ml

  const DailyNutritionGoals({
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.fibers,
    required this.water,
  });

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'fibers': fibers,
      'water': water,
    };
  }

  factory DailyNutritionGoals.fromJson(Map<String, dynamic> json) {
    return DailyNutritionGoals(
      calories: json['calories'] ?? 2000,
      proteins: (json['proteins'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      fats: (json['fats'] ?? 0.0).toDouble(),
      fibers: (json['fibers'] ?? 0.0).toDouble(),
      water: json['water'] ?? 2000,
    );
  }
}

/// Registro de refeição diária
class MealRecord {
  final String id;
  final DateTime date;
  final MealType type;
  final String name;
  final int calories;
  final double proteins;
  final double carbs;
  final double fats;
  final double fibers;
  final bool isCompleted;
  final String? notes;

  MealRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.fibers,
    required this.isCompleted,
    this.notes,
  });

  MealRecord copyWith({
    bool? isCompleted,
  }) {
    return MealRecord(
      id: id,
      date: date,
      type: type,
      name: name,
      calories: calories,
      proteins: proteins,
      carbs: carbs,
      fats: fats,
      fibers: fibers,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.name,
      'name': name,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'fibers': fibers,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }

  factory MealRecord.fromJson(Map<String, dynamic> json) {
    return MealRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: MealType.values.firstWhere((type) => type.name == json['type']),
      name: json['name'],
      calories: json['calories'],
      proteins: (json['proteins'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      fats: (json['fats'] ?? 0.0).toDouble(),
      fibers: (json['fibers'] ?? 0.0).toDouble(),
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
    );
  }
}

/// Tipo de refeição
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
  water;

  String get name {
    switch (this) {
      case MealType.breakfast:
        return 'Café da Manhã';
      case MealType.lunch:
        return 'Almoço';
      case MealType.dinner:
        return 'Jantar';
      case MealType.snack:
        return 'Lanche';
      case MealType.water:
        return 'Água';
    }
  }
}

/// Resumo nutricional do dia
class DailyNutritionSummary {
  final DateTime date;
  final DailyNutritionGoals goals;
  final List<MealRecord> meals;
  final int totalCalories;
  final double totalProteins;
  final double totalCarbs;
  final double totalFats;
  final double totalFibers;
  final int totalWater;
  final double goalCompletionRate;

  const DailyNutritionSummary({
    required this.date,
    required this.goals,
    required this.meals,
    required this.totalCalories,
    required this.totalProteins,
    required this.totalCarbs,
    required this.totalFats,
    required this.totalFibers,
    required this.totalWater,
    required this.goalCompletionRate,
  });
}

/// Serviço principal para controle de dieta e nutrição
class DietService extends ChangeNotifier {
  static const String _goalsKey = 'diet_goals';
  static const String _mealsKey = 'diet_meals';
  static const String _summaryKey = 'diet_summary';

  final IsarPreferencesRepository _prefs;

  DailyNutritionGoals? _currentGoals;
  List<MealRecord> _todayMeals = [];
  DailyNutritionSummary? _todaySummary;

  DietService(this._prefs) {
    _loadGoals();
    _loadTodayMeals();
    _calculateTodaySummary();
  }

  /// Metas nutricionais atuais
  DailyNutritionGoals get currentGoals => _currentGoals ?? DailyNutritionGoals(
        calories: 2000,
        proteins: 150.0,
        carbs: 250.0,
        fats: 65.0,
        fibers: 25.0,
        water: 2000,
      );

  /// Refeições de hoje
  List<MealRecord> get todayMeals => List.unmodifiable(_todayMeals);

  /// Resumo nutricional de hoje
  DailyNutritionSummary? get todaySummary => _todaySummary;

  /// Atualiza metas nutricionais
  Future<void> updateGoals(DailyNutritionGoals goals) async {
    _currentGoals = goals;
    await _saveGoals();
    await _calculateTodaySummary();
    
    LoggerService.instance.i('Metas nutricionais atualizadas');
    notifyListeners();
  }

  /// Adiciona refeição ao dia atual
  Future<void> addMeal(MealRecord meal) async {
    final today = DateTime.now();
    if (!_isSameDay(meal.date, today)) {
      await _clearTodayMeals();
    }

    _todayMeals.add(meal);
    await _saveTodayMeals();
    await _calculateTodaySummary();
    
    LoggerService.instance.i('Refeição adicionada: ${meal.name}');
    notifyListeners();
  }

  /// Remove refeição do dia atual
  Future<void> removeMeal(String mealId) async {
    _todayMeals.removeWhere((meal) => meal.id == mealId);
    await _saveTodayMeals();
    await _calculateTodaySummary();
    
    LoggerService.instance.i('Refeição removida: $mealId');
    notifyListeners();
  }

  /// Marca refeição como concluída
  Future<void> completeMeal(String mealId) async {
    final mealIndex = _todayMeals.indexWhere((meal) => meal.id == mealId);
    if (mealIndex != -1) {
      _todayMeals[mealIndex] = _todayMeals[mealIndex].copyWith(isCompleted: true);
      await _saveTodayMeals();
      await _calculateTodaySummary();
      LoggerService.instance.i('Refeição concluída: ${_todayMeals[mealIndex].name}');
      notifyListeners();
    }
  }

  /// Obtém resumo nutricional de um dia específico
  Future<DailyNutritionSummary?> getDaySummary(DateTime date) async {
    // Implementar busca no armazenamento quando necessário
    return null;
  }

  /// Calcula resumo nutricional do dia atual
  Future<void> _calculateTodaySummary() async {
    final totalCalories = _todayMeals.fold<int>(0, (sum, meal) => sum + meal.calories);
    final totalProteins = _todayMeals.fold<double>(0.0, (sum, meal) => sum + meal.proteins);
    final totalCarbs = _todayMeals.fold<double>(0.0, (sum, meal) => sum + meal.carbs);
    final totalFats = _todayMeals.fold<double>(0.0, (sum, meal) => sum + meal.fats);
    final totalFibers = _todayMeals.fold<double>(0.0, (sum, meal) => sum + meal.fibers);
    final totalWater = _todayMeals.where((meal) => meal.type == MealType.water).length;

    // Calcular taxa de conclusão das metas
    final goals = _currentGoals;
    double completionRate = 0.0;
    
    if (goals != null) {
      final calorieCompletion = totalCalories / goals.calories;
      final proteinCompletion = totalProteins / goals.proteins;
      final carbCompletion = totalCarbs / goals.carbs;
      final fatCompletion = totalFats / goals.fats;
      final fiberCompletion = totalFibers / goals.fibers;
      final waterCompletion = totalWater / goals.water;
      
      completionRate = (calorieCompletion + proteinCompletion + 
                      carbCompletion + fatCompletion + fiberCompletion + waterCompletion) / 6;
    }

    _todaySummary = DailyNutritionSummary(
      date: DateTime.now(),
      goals: goals ?? DailyNutritionGoals(
        calories: 2000,
        proteins: 150.0,
        carbs: 250.0,
        fats: 65.0,
        fibers: 25.0,
        water: 2000,
      ),
      meals: List.unmodifiable(_todayMeals),
      totalCalories: totalCalories,
      totalProteins: totalProteins,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
      totalFibers: totalFibers,
      totalWater: totalWater,
      goalCompletionRate: completionRate,
    );
  }

  /// Carrega metas do armazenamento local
  Future<void> _loadGoals() async {
    final goalsJson = await _prefs.getString(_goalsKey);
    if (goalsJson != null) {
      final Map<String, dynamic> goalsMap = jsonDecode(goalsJson);
      _currentGoals = DailyNutritionGoals.fromJson(goalsMap);
    } else {
      _currentGoals = DailyNutritionGoals(
        calories: 2000,
        proteins: 150.0,
        carbs: 250.0,
        fats: 65.0,
        fibers: 25.0,
        water: 2000,
      );
    }
  }

  /// Salva metas no armazenamento local
  Future<void> _saveGoals() async {
    if (_currentGoals != null) {
      await _prefs.setString(_goalsKey, jsonEncode(_currentGoals!.toJson()));
    }
  }

  /// Carrega refeições do dia atual
  Future<void> _loadTodayMeals() async {
    final mealsJson = await _prefs.getString(_mealsKey);
    if (mealsJson != null) {
      final List<dynamic> mealsList = jsonDecode(mealsJson);
      _todayMeals = mealsList.map((mealJson) => MealRecord.fromJson(mealJson as Map<String, dynamic>)).toList();
    } else {
      _todayMeals = [];
    }
  }

  /// Salva refeições do dia atual
  Future<void> _saveTodayMeals() async {
    await _prefs.setString(_mealsKey, jsonEncode(_todayMeals.map((meal) => meal.toJson()).toList()));
  }

  /// Limpa refeições do dia atual
  Future<void> _clearTodayMeals() async {
    _todayMeals.clear();
    await _saveTodayMeals();
  }

  /// Verifica se duas datas são do mesmo dia
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Reseta todos os dados do serviço
  Future<void> clearAllData() async {
    _currentGoals = null;
    _todayMeals.clear();
    _todaySummary = null;
    
    await _prefs.remove(_goalsKey);
    await _prefs.remove(_mealsKey);
    await _prefs.remove(_summaryKey);
    
    LoggerService.instance.i('Dados de dieta limpos');
    notifyListeners();
  }
}
