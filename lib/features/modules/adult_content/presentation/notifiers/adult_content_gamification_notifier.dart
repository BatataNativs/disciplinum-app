import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/adult_content/domain/entities/adult_content_module_state.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/repositories/adult_content_gamification_repository.dart';

/// Estado da gamificação do Adult Content
class AdultContentGamificationState {
  final AdultContentModuleState? gamification;
  final bool isLoading;
  final String? error;
  final bool isModuleActive;

  const AdultContentGamificationState({
    this.gamification,
    this.isLoading = false,
    this.error,
    this.isModuleActive = false,
  });

  AdultContentGamificationState copyWith({
    AdultContentModuleState? gamification,
    bool? isLoading,
    String? error,
    bool? isModuleActive,
  }) {
    return AdultContentGamificationState(
      gamification: gamification ?? this.gamification,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isModuleActive: isModuleActive ?? this.isModuleActive,
    );
  }

  int get currentStreak => gamification?.consecutiveDays ?? 0;
  int get disciplinumCount => gamification?.disciplinumCount ?? 0;
  List<String> get earnedInsignias => gamification?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => gamification?.earnedMedalhas ?? [];
  DateTime? get lastUpdated => gamification?.lastUpdated;
}

/// Notifier para gamificação do Adult Content - Plugin independente
class AdultContentGamificationNotifier extends StateNotifier<AdultContentGamificationState> {
  final AdultContentGamificationRepository _repository;

  AdultContentGamificationNotifier(this._repository) 
      : super(const AdultContentGamificationState());

  Future<void> loadGamification() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gamification = await _repository.getAdultContentState();
      if (gamification != null) {
        state = state.copyWith(
          gamification: gamification, 
          isLoading: false,
          isModuleActive: gamification.isModuleActive,
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
      final currentState = state.gamification ?? AdultContentModuleState.initial();
      final newState = currentState.copyWith(isModuleActive: true);
      await _repository.saveAdultContentState(newState);
      await _repository.syncWithSupabase(newState);
      await loadGamification();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deactivateModule() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final currentState = state.gamification ?? AdultContentModuleState.initial();
      final newState = currentState.copyWith(isModuleActive: false);
      await _repository.saveAdultContentState(newState);
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
      
      await _repository.clearAdultContentState();
      
      // Cria estado inicial preservando Madeira se existia
      final initialState = AdultContentModuleState.initial();
      if (hasMadeira) {
        final stateWithMadeira = initialState.copyWith(
          earnedInsignias: ['Madeira'],
        );
        await _repository.saveAdultContentState(stateWithMadeira);
        await _repository.syncWithSupabase(stateWithMadeira);
      } else {
        await _repository.saveAdultContentState(initialState);
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
final adultContentGamificationNotifierProvider = StateNotifierProvider<
  AdultContentGamificationNotifier,
  AdultContentGamificationState
>((ref) {
  final repository = AdultContentGamificationRepository.instance;
  return AdultContentGamificationNotifier(repository);
});

/// Provider conveniente
final adultContentGamificationStateProvider = Provider<AsyncValue<AdultContentGamificationState>>((ref) {
  final state = ref.watch(adultContentGamificationNotifierProvider);
  if (state.isLoading) return const AsyncValue.loading();
  if (state.error != null) return AsyncValue.error(state.error!, StackTrace.current);
  return AsyncValue.data(state);
});
