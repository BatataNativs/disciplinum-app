import 'package:objectbox/objectbox.dart';

@Entity()
class MealEntryEntity {
  @Id()
  int id = 0;

  String userId;
  DateTime date;
  String mealName;
  DateTime plannedTime;
  DateTime? actualTime;
  bool wasOnTime = false;
  bool wasCompleted = false;
  int? calories;
  String? notes;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  MealEntryEntity({
    required this.userId,
    required this.date,
    required this.mealName,
    required this.plannedTime,
    this.actualTime,
    this.wasOnTime = false,
    this.wasCompleted = false,
    this.calories,
    this.notes,
  })  : createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  /// Verifica se esta é a última refeição do dia
  bool isLastMealOfDay(List<MealEntryEntity> allMealsOfDay) {
    if (allMealsOfDay.isEmpty) return false;
    final sorted = allMealsOfDay.toList()
      ..sort((a, b) => a.plannedTime.compareTo(b.plannedTime));
    return sorted.last.id == id;
  }

  /// Verifica se o usuário completou todas as refeições do dia no horário
  static bool allMealsCompletedOnTime(List<MealEntryEntity> meals) {
    if (meals.isEmpty) return false;
    return meals.every((meal) => meal.wasCompleted && meal.wasOnTime);
  }

  MealEntryEntity copyWith({
    String? userId,
    DateTime? date,
    String? mealName,
    DateTime? plannedTime,
    DateTime? actualTime,
    bool? wasOnTime,
    bool? wasCompleted,
    int? calories,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final entity = MealEntryEntity(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      mealName: mealName ?? this.mealName,
      plannedTime: plannedTime ?? this.plannedTime,
    );
    entity.id = id;
    entity.actualTime = actualTime ?? this.actualTime;
    entity.wasOnTime = wasOnTime ?? this.wasOnTime;
    entity.wasCompleted = wasCompleted ?? this.wasCompleted;
    entity.calories = calories ?? this.calories;
    entity.notes = notes ?? this.notes;
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    return entity;
  }

  void touch() {
    updatedAt = DateTime.now();
  }
}
