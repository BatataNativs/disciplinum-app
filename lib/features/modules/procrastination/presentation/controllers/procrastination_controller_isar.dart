import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:disciplinum/features/modules/procrastination/domain/services/procrastination_service_isar.dart';

/// Estado do Procrastination
class ProcrastinationState {
  final bool isLoading;
  final String? error;
  final ProcrastinationConfig? config;

  const ProcrastinationState({
    this.isLoading = false,
    this.error,
    this.config,
  });

  ProcrastinationState copyWith({
    bool? isLoading,
    String? error,
    ProcrastinationConfig? config,
  }) {
    return ProcrastinationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      config: config ?? this.config,
    );
  }
}

/// Controller Riverpod para Procrastination usando Isar puro
class ProcrastinationControllerIsar extends StateNotifier<ProcrastinationState> {
  final ProcrastinationServiceIsar _service;
  
  ProcrastinationControllerIsar(this._service) : super(const ProcrastinationState()) {
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

  Future<void> updateConfig(ProcrastinationConfig config) async {
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

  Future<void> updateFocusSettings({
    int? dailyFocusMinutes,
    bool? enableAppBlocking,
    List<String>? blockedApps,
    int? blockDurationMinutes,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateFocusSettings(
        dailyFocusMinutes: dailyFocusMinutes,
        enableAppBlocking: enableAppBlocking,
        blockedApps: blockedApps,
        blockDurationMinutes: blockDurationMinutes,
      );
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> recordFocusSession(int minutes) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.recordFocusSession(minutes);
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addBlockedApp(String packageName) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.addBlockedApp(packageName);
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> removeBlockedApp(String packageName) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.removeBlockedApp(packageName);
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

  /// Getters para facilitar acesso ao config
  bool get isEnabled => state.config?.isEnabled ?? false;
  int get dailyFocusMinutes => state.config?.dailyFocusMinutes ?? 120;
  bool get enableNotifications => state.config?.enableNotifications ?? false;
  TimeOfDay get reminderTime => state.config?.reminderTime ?? const TimeOfDay(hour: 9, minute: 0);
  int get streakDays => state.config?.streakDays ?? 0;
  DateTime? get lastFocusDate => state.config?.lastFocusDate;
  int get totalFocusMinutes => state.config?.totalFocusMinutes ?? 0;
  int get longestFocusSession => state.config?.longestFocusSession ?? 0;
  bool get enableAppBlocking => state.config?.enableAppBlocking ?? false;
  List<String> get blockedApps => state.config?.blockedApps ?? [];
  int get blockDurationMinutes => state.config?.blockDurationMinutes ?? 30;

  /// Calcula o progresso diário de foco
  double get dailyProgress {
    if (dailyFocusMinutes == 0) return 0.0;
    // Assumindo que o usuário já fez uma sessão hoje (simplificado)
    final todayMinutes = totalFocusMinutes % dailyFocusMinutes;
    return todayMinutes / dailyFocusMinutes;
  }

  /// Verifica se está em streak
  bool get hasActiveStreak => streakDays > 0;

  /// Formata o tempo total de foco
  String get formattedTotalFocusTime {
    final hours = totalFocusMinutes ~/ 60;
    final minutes = totalFocusMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  /// Formata a maior sessão
  String get formattedLongestSession {
    final hours = longestFocusSession ~/ 60;
    final minutes = longestFocusSession % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }
}
