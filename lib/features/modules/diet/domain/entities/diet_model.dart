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

  DailyNutritionGoals copyWith({
    int? calories,
    double? proteins,
    double? carbs,
    double? fats,
    double? fibers,
    int? water,
  }) {
    return DailyNutritionGoals(
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      fibers: fibers ?? this.fibers,
      water: water ?? this.water,
    );
  }
}

/// Registro de refeição diária
class MealRecord {
  final String id;
  final DateTime date;
  final String type; // café, almoço, jantar, lanche
  final String description;
  final int calories;
  final double proteins;
  final double carbs;
  final double fats;
  final double fibers;
  final int water; // ml consumidos durante a refeição

  const MealRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.description,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.fibers,
    required this.water,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type,
      'description': description,
      'calories': calories,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'fibers': fibers,
      'water': water,
    };
  }

  factory MealRecord.fromJson(Map<String, dynamic> json) {
    return MealRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      description: json['description'],
      calories: json['calories'] ?? 0,
      proteins: (json['proteins'] ?? 0.0).toDouble(),
      carbs: (json['carbs'] ?? 0.0).toDouble(),
      fats: (json['fats'] ?? 0.0).toDouble(),
      fibers: (json['fibers'] ?? 0.0).toDouble(),
      water: json['water'] ?? 0,
    );
  }

  MealRecord copyWith({
    String? id,
    DateTime? date,
    String? type,
    String? description,
    int? calories,
    double? proteins,
    double? carbs,
    double? fats,
    double? fibers,
    int? water,
  }) {
    return MealRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      fibers: fibers ?? this.fibers,
      water: water ?? this.water,
    );
  }
}

/// Resumo diário de nutrição
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
  final bool goalsMet;

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
    required this.goalsMet,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'goals': goals.toJson(),
      'meals': meals.map((m) => m.toJson()).toList(),
      'totalCalories': totalCalories,
      'totalProteins': totalProteins,
      'totalCarbs': totalCarbs,
      'totalFats': totalFats,
      'totalFibers': totalFibers,
      'totalWater': totalWater,
      'goalsMet': goalsMet,
    };
  }

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) {
    return DailyNutritionSummary(
      date: DateTime.parse(json['date']),
      goals: DailyNutritionGoals.fromJson(json['goals']),
      meals: (json['meals'] as List<dynamic>?)
          ?.map((m) => MealRecord.fromJson(m))
          .toList() ?? [],
      totalCalories: json['totalCalories'] ?? 0,
      totalProteins: (json['totalProteins'] ?? 0.0).toDouble(),
      totalCarbs: (json['totalCarbs'] ?? 0.0).toDouble(),
      totalFats: (json['totalFats'] ?? 0.0).toDouble(),
      totalFibers: (json['totalFibers'] ?? 0.0).toDouble(),
      totalWater: json['totalWater'] ?? 0,
      goalsMet: json['goalsMet'] ?? false,
    );
  }

  /// Calcula percentual de meta alcançada
  double get caloriesProgress => goals.calories > 0 ? (totalCalories / goals.calories).clamp(0.0, 1.0) : 0.0;
  double get proteinsProgress => goals.proteins > 0 ? (totalProteins / goals.proteins).clamp(0.0, 1.0) : 0.0;
  double get carbsProgress => goals.carbs > 0 ? (totalCarbs / goals.carbs).clamp(0.0, 1.0) : 0.0;
  double get fatsProgress => goals.fats > 0 ? (totalFats / goals.fats).clamp(0.0, 1.0) : 0.0;
  double get fibersProgress => goals.fibers > 0 ? (totalFibers / goals.fibers).clamp(0.0, 1.0) : 0.0;
  double get waterProgress => goals.water > 0 ? (totalWater / goals.water).clamp(0.0, 1.0) : 0.0;

  DailyNutritionSummary copyWith({
    DateTime? date,
    DailyNutritionGoals? goals,
    List<MealRecord>? meals,
    int? totalCalories,
    double? totalProteins,
    double? totalCarbs,
    double? totalFats,
    double? totalFibers,
    int? totalWater,
    bool? goalsMet,
  }) {
    return DailyNutritionSummary(
      date: date ?? this.date,
      goals: goals ?? this.goals,
      meals: meals ?? this.meals,
      totalCalories: totalCalories ?? this.totalCalories,
      totalProteins: totalProteins ?? this.totalProteins,
      totalCarbs: totalCarbs ?? this.totalCarbs,
      totalFats: totalFats ?? this.totalFats,
      totalFibers: totalFibers ?? this.totalFibers,
      totalWater: totalWater ?? this.totalWater,
      goalsMet: goalsMet ?? this.goalsMet,
    );
  }
}
