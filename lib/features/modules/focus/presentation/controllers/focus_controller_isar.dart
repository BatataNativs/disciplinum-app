import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/focus/domain/services/focus_service_isar.dart';
import 'package:disciplinum/shared/domain/models/time_of_day_range.dart';

/// Estado do Focus
class FocusState {
  final bool isLoading;
  final String? error;
  final FocusConfig? config;
  final Map<int, TimeOfDayRange> focusIntervals;

  const FocusState({
    this.isLoading = false,
    this.error,
    this.config,
    this.focusIntervals = const {},
  });

  FocusState copyWith({
    bool? isLoading,
    String? error,
    FocusConfig? config,
    Map<int, TimeOfDayRange>? focusIntervals,
  }) {
    return FocusState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      config: config ?? this.config,
      focusIntervals: focusIntervals ?? this.focusIntervals,
    );
  }
}

/// Controller Riverpod para Focus usando Isar puro
class FocusControllerIsar extends StateNotifier<FocusState> {
  final FocusServiceIsar _service;
  
  FocusControllerIsar(this._service) : super(const FocusState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final config = await _service.getConfig();
      final intervals = await _service.getAllFocusIntervals();
      
      state = state.copyWith(
        config: config,
        focusIntervals: intervals,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateConfig(FocusConfig config) async {
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

  Future<void> updateDailyGoal(int minutes) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateDailyGoal(minutes);
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

  Future<void> recordFocusSession({
    required int minutes,
    required int nicheId,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.recordFocusSession(
        minutes: minutes,
        nicheId: nicheId,
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

  Future<void> saveFocusInterval({
    required int nicheId,
    required TimeOfDayRange interval,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.saveFocusInterval(
        nicheId: nicheId,
        interval: interval,
      );
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> removeFocusInterval(int nicheId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.removeFocusInterval(nicheId);
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
