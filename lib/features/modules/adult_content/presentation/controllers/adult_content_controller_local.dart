import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/adult_content/domain/services/adult_content_service_local.dart';

/// Estado do Adult Content
class AdultContentState {
  final bool isLoading;
  final String? error;
  final AdultContentConfig? config;
  final Map<String, dynamic> stats;
  final List<String> blockedApps;

  const AdultContentState({
    this.isLoading = false,
    this.error,
    this.config,
    this.stats = const {},
    this.blockedApps = const [],
  });

  AdultContentState copyWith({
    bool? isLoading,
    String? error,
    AdultContentConfig? config,
    Map<String, dynamic>? stats,
    List<String>? blockedApps,
  }) {
    return AdultContentState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      config: config ?? this.config,
      stats: stats ?? this.stats,
      blockedApps: blockedApps ?? this.blockedApps,
    );
  }
}

/// Controller Riverpod para Adult Content usando ObjectBox
class AdultContentControllerLocal extends StateNotifier<AdultContentState> {
  final AdultContentServiceLocal _service;
  
  AdultContentControllerLocal(this._service) : super(const AdultContentState()) {
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

  Future<void> updateConfig(AdultContentConfig config) async {
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

  Future<void> blockContent({required String reason, DateTime? until}) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.blockContent(reason: reason, until: until);
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> unblockContent() async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.unblockContent();
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateDailyLimit(int minutes) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.updateDailyLimit(minutes);
      await _loadData(); // Recarrega os dados
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> togglePasswordRequirement(bool requirePassword) async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.togglePasswordRequirement(requirePassword);
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

  /// Limpa o estado da gamificação (usado ao desativar módulo)
  void clearGamification() {
    state = const AdultContentState();
  }
}
