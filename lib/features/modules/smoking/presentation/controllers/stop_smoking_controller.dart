import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/smoking/domain/services/smoking_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/models/smoking_settings_model.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Estado da tela Stop Smoking
class StopSmokingState {
  final bool isLoading;
  final SmokingSettingsModel? smokingData;
  final String? error;

  const StopSmokingState({
    required this.isLoading,
    this.smokingData,
    this.error,
  });

  factory StopSmokingState.initial() => const StopSmokingState(
    isLoading: false,
  );

  StopSmokingState copyWith({
    bool? isLoading,
    SmokingSettingsModel? smokingData,
    String? error,
  }) {
    return StopSmokingState(
      isLoading: isLoading ?? this.isLoading,
      smokingData: smokingData ?? this.smokingData,
      error: error ?? this.error,
    );
  }
}

/// Controller Riverpod para Stop Smoking
class StopSmokingController extends StateNotifier<StopSmokingState> {
  final SmokingService _smokingService;

  StopSmokingController(this._smokingService) : super(StopSmokingState.initial());

  Future<void> loadSmokingData() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final smokingData = await _smokingService.getSettings();
      state = state.copyWith(
        isLoading: false,
        smokingData: smokingData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> saveSmokingSettings(SmokingSettingsModel settings) async {
    try {
      await _smokingService.saveSettings(settings);
      
      // Atualiza estado local
      state = state.copyWith(smokingData: settings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  Future<void> resetSmokingData() async {
    try {
      await _smokingService.resetAllData();
      
      // Atualiza estado local
      state = state.copyWith(
        smokingData: null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Limpa o estado da gamificação (usado ao desativar módulo)
  void clearGamification() {
    state = StopSmokingState.initial();
  }
}

/// Provider para StopSmokingController
final stopSmokingControllerProvider = StateNotifierProvider<StopSmokingController, StopSmokingState>((ref) {
  final smokingService = ref.watch(smokingServiceProvider);
  return StopSmokingController(smokingService);
});
