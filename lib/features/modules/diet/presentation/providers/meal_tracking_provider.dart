import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/meal_entry_entity.dart';
import 'package:disciplinum/features/modules/diet/domain/repositories/meal_entry_repository.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

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

  /// Função para determinar período do dia
  String _getDayPeriodName(int hour) {
    if (hour >= 0 && hour < 6) {
      return 'Refeição da madrugada';
    } else if (hour >= 6 && hour < 12) {
      return 'Refeição da manhã';
    } else if (hour >= 12 && hour < 18) {
      return 'Refeição da tarde';
    } else {
      return 'Refeição da noite';
    }
  }

  /// Carrega dados do usuário
  Future<void> loadData() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final now = DateTime.now();
      final todayMeals = await _repository.getMealsByDate(_userId, now);
      final history = await _getHistory(days: 7);
      final streak = await _calculateStreak();

      state = state.copyWith(
        isLoading: false,
        todayMeals: todayMeals,
        history: history,
        streak: streak,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar dados: $e',
      );
    }
  }

  /// Limpa todas as refeições do dia atual (usado ao desativar módulo)
  Future<void> clearTodayMeals() async {
    try {
      final now = DateTime.now();
      final todayMeals = await _repository.getMealsByDate(_userId, now);
      
      // Remove todas as refeições do dia atual
      for (final meal in todayMeals) {
        await _repository.deleteMeal(meal.id);
      }
      
      // Recarrega os dados para refletir a limpeza
      await loadData();
    } catch (e) {
      LoggerService.instance.e('Erro ao limpar refeições do dia: $e');
      state = state.copyWith(error: 'Erro ao limpar refeições: $e');
    }
  }

  /// Registra uma refeição como feita ou não feita
  Future<void> recordMeal(TimeOfDay time, {required bool done}) async {
    try {
      LoggerService.instance.i('recordMeal chamado - time: ${time.hour}:${time.minute}, done: $done');
      LoggerService.instance.i('userId: $_userId');
      
      final now = DateTime.now();
      final plannedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);

      // Busca refeição existente ou cria nova
      final meals = await _repository.getMealsByDate(_userId, now);
      LoggerService.instance.i('Refeições encontradas para hoje: ${meals.length}');
      
      final existing = meals.firstWhere(
        (m) => m.plannedTime.hour == time.hour && m.plannedTime.minute == time.minute,
        orElse: () {
          LoggerService.instance.i('Criando nova refeição para horário ${time.hour}:${time.minute}');
          return MealEntryEntity(
            userId: _userId,
            date: now,
            mealName: _getDayPeriodName(time.hour),
            plannedTime: plannedTime,
          );
        },
      );

      LoggerService.instance.i('Refeição encontrada/criada: ${existing.mealName} - wasCompleted: ${existing.wasCompleted}');

      // Verifica se foi no horário (tolerância de 30 min)
      final actualTime = DateTime.now();
      final difference = actualTime.difference(plannedTime).inMinutes.abs();
      final wasOnTime = difference <= 30;

      LoggerService.instance.i('Diferença de horário: $difference min, wasOnTime: $wasOnTime');

      final updated = existing.copyWith(
        wasCompleted: done,
        wasOnTime: done && wasOnTime,
        actualTime: done ? actualTime : null,
      );

      LoggerService.instance.i('Salvando refeição atualizada...');
      await _repository.saveMeal(updated);

      // Recarrega dados
      LoggerService.instance.i('Recarregando dados...');
      await loadData();
      LoggerService.instance.i('recordMeal concluído com sucesso');
    } catch (e) {
      LoggerService.instance.e('Erro em recordMeal: $e');
      state = state.copyWith(error: 'Erro ao registrar refeição: $e');
    }
  }

  /// Cria refeições padrão para o dia baseado nos horários configurados
  Future<void> createDefaultMealsForDay(List<TimeOfDay> mealTimes, List<String> mealNames) async {
    try {
      final now = DateTime.now();
      final existingMeals = await _repository.getMealsByDate(_userId, now);
      
      // Sempre garante que as refeições existam para os horários atuais
      // Se não existirem refeições, cria todas
      // Se existirem, verifica se precisa criar alguma que falta
      if (existingMeals.isEmpty) {
        // Cria todas as refeições
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
      } else {
        // Verifica se alguma refeição está faltando e cria se necessário
        for (int i = 0; i < mealTimes.length && i < mealNames.length; i++) {
          final time = mealTimes[i];
          final plannedTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
          
          final exists = existingMeals.any((meal) => 
            meal.plannedTime.hour == time.hour && meal.plannedTime.minute == time.minute);
          
          if (!exists) {
            final meal = MealEntryEntity(
              userId: _userId,
              date: now,
              mealName: mealNames[i],
              plannedTime: plannedTime,
            );
            await _repository.saveMeal(meal);
          }
        }
      }

      await loadData();
    } catch (e) {
      state = state.copyWith(error: 'Erro ao criar refeições padrão: $e');
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
