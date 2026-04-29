import 'package:disciplinum/core/database/objectbox_service.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/objectbox.g.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/meal_entry_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  // ===== SINCRONIZAÇÃO COM CLOUD (Supabase) =====

  /// Sincroniza todas as refeições do usuário com o Supabase
  Future<void> syncWithSupabase(String userId) async {
    try {
      // Busca todas as refeições do usuário (não só de uma data)
      final query = _box.query(MealEntryEntity_.userId.equals(userId)).build();
      final meals = query.find();
      query.close();

      final mealsData = meals.map((meal) => {
        'id': meal.id,
        'user_id': userId,
        'date': meal.date.toIso8601String(),
        'meal_name': meal.mealName,
        'planned_time': meal.plannedTime.toIso8601String(),
        'actual_time': meal.actualTime?.toIso8601String(),
        'was_on_time': meal.wasOnTime,
        'was_completed': meal.wasCompleted,
        'calories': meal.calories,
        'notes': meal.notes,
        'created_at': meal.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).toList();

      await Supabase.instance.client.from('user_module_settings').upsert({
        'user_id': userId,
        'module_id': 'diet_meals',
        'meals_data': mealsData,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, module_id');

      LoggerService.instance.i('${meals.length} refeições sincronizadas com Supabase');
    } catch (e) {
      LoggerService.instance.e('Erro ao sincronizar refeições com Supabase', error: e);
    }
  }

  /// Carrega refeições do Supabase
  Future<List<MealEntryEntity>> loadFromSupabase(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('user_module_settings')
          .select()
          .eq('user_id', userId)
          .eq('module_id', 'diet_meals')
          .maybeSingle();

      if (response == null || response['meals_data'] == null) {
        return [];
      }

      final mealsData = response['meals_data'] as List<dynamic>;
      final meals = mealsData.map((data) {
        final entity = MealEntryEntity(
          userId: userId,
          date: DateTime.parse(data['date']),
          mealName: data['meal_name'],
          plannedTime: DateTime.parse(data['planned_time']),
        );
        entity.id = data['id'] ?? 0;
        entity.actualTime = data['actual_time'] != null 
            ? DateTime.parse(data['actual_time']) 
            : null;
        entity.wasOnTime = data['was_on_time'] ?? false;
        entity.wasCompleted = data['was_completed'] ?? false;
        entity.calories = data['calories'];
        entity.notes = data['notes'];
        entity.createdAt = data['created_at'] != null 
            ? DateTime.parse(data['created_at']) 
            : DateTime.now();
        entity.updatedAt = data['updated_at'] != null 
            ? DateTime.parse(data['updated_at']) 
            : DateTime.now();
        
        return entity;
      }).toList();

      LoggerService.instance.i('${meals.length} refeições carregadas do Supabase');
      return meals;
    } catch (e) {
      LoggerService.instance.e('Erro ao carregar refeições do Supabase', error: e);
      return [];
    }
  }

  /// Sincronização bidirecional completa
  Future<void> performFullSync(String userId) async {
    try {
      // Carrega da nuvem primeiro
      final cloudMeals = await loadFromSupabase(userId);
      
      if (cloudMeals.isNotEmpty) {
        // Salva localmente
        for (final meal in cloudMeals) {
          _box.put(meal);
        }
        LoggerService.instance.i('Sincronização: ${cloudMeals.length} refeições da nuvem salvas localmente');
      } else {
        // Se não tem na nuvem, envia os locais
        await syncWithSupabase(userId);
      }
    } catch (e) {
      LoggerService.instance.e('Erro na sincronização completa de refeições', error: e);
    }
  }
}
