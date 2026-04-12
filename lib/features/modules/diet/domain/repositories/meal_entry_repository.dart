import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/meal_entry_entity.dart';

/// Repository para gerenciar registros de refeições
class MealEntryRepository {
  static final MealEntryRepository _instance = MealEntryRepository._internal();
  static MealEntryRepository get instance => _instance;

  MealEntryRepository._internal();

  Box<MealEntryEntity> get _box => ObjectBoxService.instance.store.box<MealEntryEntity>();

  /// Salva uma refeição
  Future<void> saveMeal(MealEntryEntity meal) async {
    meal.touch();
    _box.put(meal);
  }

  /// Obtém todas as refeições de um usuário em uma data específica
  Future<List<MealEntryEntity>> getMealsByDate(String userId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Try multiple compatible ways of ObjectBox querying for dates:
    // Some versions accept Datetime directly
    final query = _box.query(
      MealEntryEntity_.userId.equals(userId)
        .and(MealEntryEntity_.date.betweenDate(
          startOfDay, 
          endOfDay.subtract(const Duration(milliseconds: 1))
        ))
    ).order(MealEntryEntity_.plannedTime).build();
    
    final result = query.find();
    query.close();
    return result;
  }

  /// Obtém a refeição por ID
  Future<MealEntryEntity?> getMealById(int id) async {
    return _box.get(id);
  }

  /// Marca uma refeição como completada
  Future<void> markMealAsCompleted(
    int mealId, {
    required bool wasOnTime,
    DateTime? actualTime,
    int? calories,
    String? notes,
  }) async {
    final meal = await getMealById(mealId);
    if (meal == null) return;

    final updated = meal.copyWith(
      wasCompleted: true,
      wasOnTime: wasOnTime,
      actualTime: actualTime ?? DateTime.now(),
      calories: calories,
      notes: notes,
    );

    await saveMeal(updated);
  }

  /// Verifica se todas as refeições do dia foram completadas no horário
  Future<bool> allMealsCompletedOnTime(String userId, DateTime date) async {
    final meals = await getMealsByDate(userId, date);
    if (meals.isEmpty) return false;
    return meals.every((meal) => meal.wasCompleted && meal.wasOnTime);
  }

  /// Obtém a última refeição do dia (maior horário)
  Future<MealEntryEntity?> getLastMealOfDay(String userId, DateTime date) async {
    final meals = await getMealsByDate(userId, date);
    if (meals.isEmpty) return null;
    return meals.last;
  }

  /// Deleta uma refeição
  Future<void> deleteMeal(int id) async {
    _box.remove(id);
  }

  /// Deleta todas as refeições de um usuário
  Future<void> deleteAllUserMeals(String userId) async {
    final query = _box.query(MealEntryEntity_.userId.equals(userId)).build();
    final ids = query.findIds();
    _box.removeMany(ids);
    query.close();
  }

  /// Cria refeições padrão para um dia (baseado nos horários configurados)
  Future<List<MealEntryEntity>> createDefaultMealsForDay(
    String userId,
    DateTime date,
    List<String> mealTimes,
    List<String> mealNames,
  ) async {
    final meals = <MealEntryEntity>[];

    for (int i = 0; i < mealTimes.length && i < mealNames.length; i++) {
      final timeParts = mealTimes[i].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final plannedTime = DateTime(date.year, date.month, date.day, hour, minute);

      final meal = MealEntryEntity(
        userId: userId,
        date: date,
        mealName: mealNames[i],
        plannedTime: plannedTime,
      );

      await saveMeal(meal);
      meals.add(meal);
    }

    return meals;
  }

  /// Registra uma refeição a partir de uma notificação (ação do usuário)
  /// Usado pelo NotificationService quando usuário clica em "Sim" ou "Não" na notificação
  Future<void> recordMealFromNotification(
    int hour,
    int minute, {
    required bool done,
    required String userId,
  }) async {
    final now = DateTime.now();
    
    // Busca refeição existente para este horário hoje
    final meals = await getMealsByDate(userId, now);
    final existing = meals.firstWhere(
      (m) => m.plannedTime.hour == hour && m.plannedTime.minute == minute,
      orElse: () => MealEntryEntity(
        userId: userId,
        date: now,
        mealName: 'Refeição das ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
        plannedTime: DateTime(now.year, now.month, now.day, hour, minute),
      ),
    );

    // Calcula se foi no horário (tolerância de 30 min)
    final actualTime = DateTime.now();
    final plannedTime = DateTime(now.year, now.month, now.day, hour, minute);
    final difference = actualTime.difference(plannedTime).inMinutes.abs();
    final wasOnTime = done && difference <= 30;

    final updated = existing.copyWith(
      wasCompleted: done,
      wasOnTime: wasOnTime,
      actualTime: done ? actualTime : null,
    );

    await saveMeal(updated);
  }
}
