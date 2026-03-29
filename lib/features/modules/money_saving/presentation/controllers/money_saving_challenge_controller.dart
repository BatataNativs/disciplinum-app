import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/money_saving/domain/services/money_saving_challenge_service.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Estado da tela Money Saving Challenge
class MoneySavingChallengeState {
  final bool isLoading;
  final MoneySavingChallengeModel? challengeData;
  final String? error;

  const MoneySavingChallengeState({
    required this.isLoading,
    this.challengeData,
    this.error,
  });

  factory MoneySavingChallengeState.initial() => const MoneySavingChallengeState(
    isLoading: false,
  );

  MoneySavingChallengeState copyWith({
    bool? isLoading,
    MoneySavingChallengeModel? challengeData,
    String? error,
  }) {
    return MoneySavingChallengeState(
      isLoading: isLoading ?? this.isLoading,
      challengeData: challengeData ?? this.challengeData,
      error: error ?? this.error,
    );
  }
}

/// Controller Riverpod para Money Saving Challenge
class MoneySavingChallengeController extends StateNotifier<MoneySavingChallengeState> {
  final MoneySavingChallengeService _moneySavingService;

  MoneySavingChallengeController(this._moneySavingService) : super(MoneySavingChallengeState.initial());

  Future<void> loadChallengeData() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final challengeData = _moneySavingService.getActiveChallenge();
      state = state.copyWith(
        isLoading: false,
        challengeData: challengeData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  Future<void> saveChallengeSettings(MoneySavingChallengeModel settings) async {
    try {
      await _moneySavingService.saveChallenge(settings);
      
      // Atualiza estado local
      state = state.copyWith(challengeData: settings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  Future<void> createNewChallenge(MoneySavingChallengeModel challenge) async {
    try {
      await _moneySavingService.createChallenge(
        title: challenge.title,
        targetAmount: challenge.targetAmount,
        periodValue: challenge.periodValue,
        periodType: challenge.periodType,
        gridSize: challenge.gridSize,
        minValue: challenge.minValue,
        maxValue: challenge.maxValue,
        currency: challenge.currency,
      );
      
      // Atualiza estado local
      state = state.copyWith(challengeData: challenge);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  Future<void> resetChallengeData() async {
    try {
      await _moneySavingService.resetAllData();
      
      // Atualiza estado local
      state = state.copyWith(
        challengeData: null,
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
}

/// Provider para MoneySavingChallengeController
final moneySavingChallengeControllerProvider = StateNotifierProvider<MoneySavingChallengeController, MoneySavingChallengeState>((ref) {
  final moneySavingService = ref.watch(moneySavingChallengeServiceProvider);
  final controller = MoneySavingChallengeController(moneySavingService);
  
  return controller;
});
