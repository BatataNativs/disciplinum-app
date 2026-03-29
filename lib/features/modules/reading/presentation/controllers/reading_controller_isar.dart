import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/reading/domain/services/reading_service_isar.dart';

/// Estado do Reading
class ReadingState {
  final bool isLoading;
  final String? error;
  final ReadingConfig? config;

  const ReadingState({
    this.isLoading = false,
    this.error,
    this.config,
  });

  ReadingState copyWith({
    bool? isLoading,
    String? error,
    ReadingConfig? config,
  }) {
    return ReadingState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      config: config ?? this.config,
    );
  }
}

/// Controller Riverpod para Reading usando Isar puro
class ReadingControllerIsar extends StateNotifier<ReadingState> {
  final ReadingServiceIsar _service;
  
  ReadingControllerIsar(this._service) : super(const ReadingState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final config = await _service.getConfig();
      
      state = state.copyWith(
        config: config,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateConfig(ReadingConfig config) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.saveConfig(config);
      
      state = state.copyWith(
        config: config,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateNotificationSettings({
    required bool enableNotifications,
    TimeOfDay? reminderTime,
    bool? enableDailyReminder,
    bool? enableStreakReminder,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateNotificationSettings(
        enableNotifications: enableNotifications,
        reminderTime: reminderTime,
        enableDailyReminder: enableDailyReminder,
        enableStreakReminder: enableStreakReminder,
      );
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateGoals({
    int? dailyPagesGoal,
    int? weeklyBooksGoal,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateGoals(
        dailyPagesGoal: dailyPagesGoal,
        weeklyBooksGoal: weeklyBooksGoal,
      );
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> recordReadingSession() async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.recordReadingSession();
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> resetStreak() async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.resetStreak();
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> clearAllData() async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.clearAllData();
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Verifica se deve notificar sobre streak
  bool get shouldNotifyStreak {
    if (state.config == null) return false;
    return _service.shouldNotifyStreak(state.config!);
  }

  /// Getters para facilitar acesso ao config
  bool get enableNotifications => state.config?.enableNotifications ?? false;
  TimeOfDay get reminderTime => state.config?.reminderTime ?? const TimeOfDay(hour: 20, minute: 0);
  bool get enableDailyReminder => state.config?.enableDailyReminder ?? false;
  bool get enableStreakReminder => state.config?.enableStreakReminder ?? false;
  int get currentStreak => state.config?.currentStreak ?? 0;
  DateTime? get lastReadingDate => state.config?.lastReadingDate;
  int get longestStreakDays => state.config?.longestStreakDays ?? 0;
  int get dailyPagesGoal => state.config?.dailyPagesGoal ?? 20;
  int get weeklyBooksGoal => state.config?.weeklyBooksGoal ?? 1;
}
