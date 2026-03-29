import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/diet/domain/services/diet_service_isar.dart';

/// Estado do Diet
class DietState {
  final bool isLoading;
  final String? error;
  final DietConfig? config;

  const DietState({
    this.isLoading = false,
    this.error,
    this.config,
  });

  DietState copyWith({
    bool? isLoading,
    String? error,
    DietConfig? config,
  }) {
    return DietState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      config: config ?? this.config,
    );
  }
}

/// Controller Riverpod para Diet usando Isar puro
class DietControllerIsar extends StateNotifier<DietState> {
  final DietServiceIsar _service;
  
  DietControllerIsar(this._service) : super(const DietState()) {
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

  Future<void> updateConfig(DietConfig config) async {
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

  Future<void> updateGoals({
    required int calories,
    required double proteins,
    required double carbs,
    required double fats,
    double fiber = 25.0,
    double water = 2000.0,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final goals = DailyNutritionGoals(
        calories: calories,
        proteins: proteins,
        carbs: carbs,
        fats: fats,
        fiber: fiber,
        water: water,
      );
      
      await _service.updateGoals(goals);
      await _loadData(); // Recarrega os dados
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
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateNotificationSettings(
        enableNotifications: enableNotifications,
        reminderTime: reminderTime,
      );
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> incrementStreak() async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.incrementStreak();
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

  Future<void> addWeightLost(double weightKg) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.addWeightLost(weightKg);
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
}
