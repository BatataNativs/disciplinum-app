import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/meal_entry_entity.dart';
import 'package:disciplinum/features/modules/diet/domain/repositories/meal_entry_repository.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Estado do registro de refeições
class MealTrackingState {
  final List<MealEntryEntity> todayMeals;
  final List<DaySummary> history;
  final int streak;
  final bool isLoading;
  final String? error;

  const MealTrackingState({
    this.todayMeals = const [],
    this.history = const [],
    this.streak = 0,
    this.isLoading = false,
    this.error,
  });

  MealTrackingState copyWith({
    List<MealEntryEntity>? todayMeals,
    List<DaySummary>? history,
    int? streak,
    bool? isLoading,
    String? error,
  }) {
    return MealTrackingState(
      todayMeals: todayMeals ?? this.todayMeals,
      history: history ?? this.history,
      streak: streak ?? this.streak,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

/// Resumo de um dia
class DaySummary {
  final DateTime date;
  final int totalMeals;
  final int doneMeals;
  final int missedMeals;
  final bool isSuccessful;

  const DaySummary({
    required this.date,
    required this.totalMeals,
    required this.doneMeals,
    required this.missedMeals,
    required this.isSuccessful,
  });
}

/// StateNotifier para gerenciamento de refeições (Riverpod puro)
class MealTrackingNotifier extends StateNotifier<MealTrackingState> {
  final MealEntryRepository _repository;
  final String _userId;

  MealTrackingNotifier(this._repository, this._userId) : super(const MealTrackingState());

  /// Carrega dados de hoje e histórico
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final today = DateTime.now();
      final meals = await _repository.getMealsByDate(_userId, today);
      final history = await _getHistory(days: 7);
      final streak = await _calculateStreak();

      state = state.copyWith(
        todayMeals: meals,
        history: history,
        streak: streak,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar dados: $e',
      );
    }
  }

  /// Registra uma refeição como feita ou não feita
  Future<void> recordMeal(TimeOfDay time, {required bool done}) async {
    try {
      final now = DateTime.now();
      final plannedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);

      // Busca refeição existente ou cria nova
      final meals = await _repository.getMealsByDate(_userId, now);
      final existing = meals.firstWhere(
        (m) => m.plannedTime.hour == time.hour && m.plannedTime.minute == time.minute,
        orElse: () => MealEntryEntity(
          userId: _userId,
          date: now,
          mealName: 'Refeição das ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
          plannedTime: plannedTime,
        ),
      );

      // Verifica se foi no horário (tolerância de 30 min)
      final actualTime = DateTime.now();
      final difference = actualTime.difference(plannedTime).inMinutes.abs();
      final wasOnTime = difference <= 30;

      final updated = existing.copyWith(
        wasCompleted: done,
        wasOnTime: done && wasOnTime,
        actualTime: done ? actualTime : null,
      );

      await _repository.saveMeal(updated);

      // Recarrega dados
      await loadData();
    } catch (e) {
      state = state.copyWith(error: 'Erro ao registrar refeição: $e');
    }
  }

  /// Cria refeições padrão para o dia baseado nos horários configurados
  Future<void> createDefaultMealsForDay(List<TimeOfDay> mealTimes, List<String> mealNames) async {
    try {
      final now = DateTime.now();
      final existingMeals = await _repository.getMealsByDate(_userId, now);
      
      // Só cria se não existirem refeições para hoje
      if (existingMeals.isNotEmpty) return;

      for (int i = 0; i < mealTimes.length && i < mealNames.length; i++) {
        final time = mealTimes[i];
        final plannedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);

        final meal = MealEntryEntity(
          userId: _userId,
          date: now,
          mealName: mealNames[i],
          plannedTime: plannedTime,
        );

        await _repository.saveMeal(meal);
      }

      await loadData();
    } catch (e) {
      state = state.copyWith(error: 'Erro ao criar refeições: $e');
    }
  }

  /// Verifica se é a última refeição do dia
  bool isLastMealTime(List<TimeOfDay> times, TimeOfDay current) {
    if (times.isEmpty) return false;
    final sorted = times.toList()..sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));
    final last = sorted.last;
    return current.hour == last.hour && current.minute == last.minute;
  }

  int _timeToMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  /// Busca histórico dos últimos N dias
  Future<List<DaySummary>> _getHistory({int days = 7}) async {
    final today = DateTime.now();
    final List<DaySummary> summaries = [];

    for (int i = 0; i < days; i++) {
      final date = today.subtract(Duration(days: i));
      final meals = await _repository.getMealsByDate(_userId, date);

      if (meals.isEmpty) continue;

      int doneCount = 0;
      int missedCount = 0;
      for (final meal in meals) {
        if (meal.wasCompleted && meal.wasOnTime) {
          doneCount++;
        } else {
          missedCount++;
        }
      }

      // Dia bem-sucedido apenas se TODAS as refeições foram feitas no horário
      final isSuccessful = missedCount == 0 && doneCount == meals.length;

      summaries.add(DaySummary(
        date: date,
        totalMeals: meals.length,
        doneMeals: doneCount,
        missedMeals: missedCount,
        isSuccessful: isSuccessful,
      ));
    }

    return summaries.reversed.toList();
  }

  /// Calcula streak atual
  Future<int> _calculateStreak() async {
    final history = await _getHistory(days: 30);
    if (history.isEmpty) return 0;

    int streak = 0;
    final sortedDesc = history.reversed.toList();

    for (final day in sortedDesc) {
      if (day.isSuccessful) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Verifica se todas as refeições de hoje foram completadas no horário
  Future<bool> allMealsCompletedToday() async {
    final today = DateTime.now();
    return await _repository.allMealsCompletedOnTime(_userId, today);
  }

  /// Limpa todos os registros
  Future<void> clearAllMeals() async {
    try {
      await _repository.deleteAllUserMeals(_userId);
      await loadData();
    } catch (e) {
      state = state.copyWith(error: 'Erro ao limpar histórico: $e');
    }
  }
}

/// Provider para o MealEntryRepository
final mealEntryRepositoryProvider = Provider<MealEntryRepository>((ref) {
  return MealEntryRepository.instance;
});

/// Provider para o MealTrackingNotifier (Riverpod puro)
final mealTrackingProvider = StateNotifierProvider<MealTrackingNotifier, MealTrackingState>((ref) {
  final repository = ref.watch(mealEntryRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  return MealTrackingNotifier(repository, userId);
});
