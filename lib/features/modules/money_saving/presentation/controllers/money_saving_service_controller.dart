import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/money_saving/domain/services/money_saving_challenge_service.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_challenge_model.dart';
import 'package:disciplinum/core/di/providers.dart';

/// Controller Riverpod para Money Saving Challenge Service
/// Substitui ChangeNotifier por StateNotifier
class MoneySavingServiceController extends StateNotifier<MoneySavingServiceState> {
  final MoneySavingChallengeService _service;
  
  MoneySavingServiceController(this._service) : super(const MoneySavingServiceState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final challenges = _service.challenges;
      final activeChallenge = _service.activeChallenge;
      final totalContributions = _service.totalContributions;
      
      state = state.copyWith(
        challenges: challenges,
        activeChallenge: activeChallenge,
        totalContributions: totalContributions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createChallenge(MoneySavingChallengeModel challenge) async {
    try {
      await _service.createChallenge(
        title: challenge.title,
        targetAmount: challenge.targetAmount,
        periodValue: challenge.periodValue,
        periodType: challenge.periodType,
        gridSize: challenge.gridSize,
        minValue: challenge.minValue,
        maxValue: challenge.maxValue,
        currency: challenge.currency,
      );
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateChallenge(MoneySavingChallengeModel challenge) async {
    try {
      await _service.updateChallenge(challenge);
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteChallenge(String challengeId) async {
    try {
      await _service.deleteChallenge(challengeId);
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addContribution(String challengeId, double amount) async {
    try {
      // O serviço usa amount para adicionar contribuição ao desafio ativo
      // Se quisermos adicionar a um desafio específico, o serviço precisa suportar isso.
      // Por enquanto, usamos o método addContribution do serviço que foca no ativo.
      await _service.addContribution(amount);
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> setActiveChallenge(String challengeId) async {
    try {
      await _service.setActiveChallenge(challengeId);
      await _loadData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Estado do MoneySavingServiceController
class MoneySavingServiceState {
  final List<MoneySavingChallengeModel> challenges;
  final MoneySavingChallengeModel? activeChallenge;
  final double totalContributions;
  final bool isLoading;
  final String? error;

  const MoneySavingServiceState({
    this.challenges = const [],
    this.activeChallenge,
    this.totalContributions = 0.0,
    this.isLoading = false,
    this.error,
  });

  MoneySavingServiceState copyWith({
    List<MoneySavingChallengeModel>? challenges,
    MoneySavingChallengeModel? activeChallenge,
    double? totalContributions,
    bool? isLoading,
    String? error,
  }) {
    return MoneySavingServiceState(
      challenges: challenges ?? this.challenges,
      activeChallenge: activeChallenge ?? this.activeChallenge,
      totalContributions: totalContributions ?? this.totalContributions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Calcula estatísticas derivadas
  int get totalChallenges => challenges.length;
  
  double get activeChallengeProgress {
    if (activeChallenge == null) return 0.0;
    return activeChallenge!.progressPercent;
  }

  double get totalSaved {
    return challenges.fold(0.0, (sum, challenge) => sum + challenge.totalSaved);
  }

  double get totalTarget {
    return challenges.fold(0.0, (sum, challenge) => sum + challenge.targetAmount);
  }

  double get overallProgress {
    if (totalTarget == 0.0) return 0.0;
    return (totalSaved / totalTarget).clamp(0.0, 1.0);
  }

  List<MoneySavingChallengeModel> get completedChallenges {
    return challenges.where((challenge) => challenge.isComplete).toList();
  }

  int get completedChallengesCount => completedChallenges.length;
}

/// Provider para o MoneySavingServiceController
final moneySavingServiceControllerProvider = StateNotifierProvider<MoneySavingServiceController, MoneySavingServiceState>((ref) {
  final service = ref.watch(moneySavingChallengeServiceProvider);
  return MoneySavingServiceController(service);
});
