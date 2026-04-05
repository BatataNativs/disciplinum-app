import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/spending/domain/entities/spending_module_state.dart';
import 'package:disciplinum/features/modules/spending/gamification/domain/repositories/spending_gamification_repository.dart';

/// Estado da gamificação do Spending
class SpendingGamificationState {
  final SpendingModuleState? gamification;
  final bool isLoading;
  final String? error;
  final bool isModuleActive;

  const SpendingGamificationState({
    this.gamification,
    this.isLoading = false,
    this.error,
    this.isModuleActive = false,
  });

  SpendingGamificationState copyWith({
    SpendingModuleState? gamification,
    bool? isLoading,
    String? error,
    bool? isModuleActive,
  }) {
    return SpendingGamificationState(
      gamification: gamification ?? this.gamification,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isModuleActive: isModuleActive ?? this.isModuleActive,
    );
  }

  int get currentStreak => gamification?.consecutiveDays ?? 0;
  double get totalMoneySaved => gamification?.totalMoneySaved ?? 0.0;
  List<String> get earnedInsignias => gamification?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => gamification?.earnedMedalhas ?? [];
  DateTime? get lastUpdated => gamification?.lastUpdated;
}

/// Notifier para gamificação do Spending - Plugin independente
class SpendingGamificationNotifier extends StateNotifier<SpendingGamificationState> {
  final SpendingGamificationRepository _repository;

  SpendingGamificationNotifier(this._repository) 
      : super(const SpendingGamificationState());

  Future<void> loadGamification() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gamification = await _repository.getSpendingState();
      if (gamification != null) {
        state = state.copyWith(
          gamification: gamification, 
          isLoading: false,
          isModuleActive: gamification.isActive,
        );
      } else {
        state = state.copyWith(isLoading: false, isModuleActive: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> activateModule() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final currentState = state.gamification ?? SpendingModuleState.initial();
      final newState = currentState.copyWith(isActive: true);
      await _repository.saveSpendingState(newState);
      await _repository.syncWithSupabase(newState);
      await loadGamification();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deactivateModule() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final currentState = state.gamification ?? SpendingModuleState.initial();
      final newState = currentState.copyWith(isActive: false);
      await _repository.saveSpendingState(newState);
      await _repository.syncWithSupabase(newState);
      state = state.copyWith(isModuleActive: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetProgress() async {
    try {
      // Preserva a insígnia Madeira (incentivo para tentar novamente)
      final current = state.gamification;
      final hasMadeira = current?.earnedInsignias.contains('Madeira') ?? false;
      
      await _repository.clearSpendingState();
      
      // Cria estado inicial preservando Madeira se existia
      final initialState = SpendingModuleState.initial();
      if (hasMadeira) {
        final stateWithMadeira = initialState.copyWith(
          earnedInsignias: ['Madeira'],
        );
        await _repository.saveSpendingState(stateWithMadeira);
        await _repository.syncWithSupabase(stateWithMadeira);
      } else {
        await _repository.saveSpendingState(initialState);
        await _repository.syncWithSupabase(initialState);
      }
      
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

/// Provider do Notifier
final spendingGamificationNotifierProvider = StateNotifierProvider<
  SpendingGamificationNotifier,
  SpendingGamificationState
>((ref) {
  final repository = SpendingGamificationRepository.instance;
  return SpendingGamificationNotifier(repository);
});

/// Provider conveniente
final spendingGamificationStateProvider = Provider<AsyncValue<SpendingGamificationState>>((ref) {
  final state = ref.watch(spendingGamificationNotifierProvider);
  if (state.isLoading) return const AsyncValue.loading();
  if (state.error != null) return AsyncValue.error(state.error!, StackTrace.current);
  return AsyncValue.data(state);
});
