import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/diet/domain/entities/diet_module_state.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/repositories/diet_gamification_repository.dart';
import 'package:disciplinum/features/modules/diet/gamification/domain/services/diet_celebration_service.dart';

/// Estado da gamificação do Diet
class DietGamificationState {
  final DietModuleState? gamification;
  final bool isLoading;
  final String? error;
  final bool isModuleActive;

  const DietGamificationState({
    this.gamification,
    this.isLoading = false,
    this.error,
    this.isModuleActive = false,
  });

  DietGamificationState copyWith({
    DietModuleState? gamification,
    bool? isLoading,
    String? error,
    bool? isModuleActive,
  }) {
    return DietGamificationState(
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

/// Notifier para gamificação do Diet - Plugin independente
class DietGamificationNotifier extends StateNotifier<DietGamificationState> {
  final DietGamificationRepository _repository;

  DietGamificationNotifier(this._repository) 
      : super(const DietGamificationState());

  Future<void> loadGamification() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gamification = await _repository.getDietState();
      if (gamification != null) {
        DietModuleState effectiveGamification = gamification;
        if (effectiveGamification.isModuleActive && !effectiveGamification.earnedInsignias.any((i) => i.toLowerCase() == 'madeira')) {
          effectiveGamification = effectiveGamification.copyWith(
            earnedInsignias: [...effectiveGamification.earnedInsignias, 'madeira'],
          );
          await _repository.saveDietState(effectiveGamification);
          DietCelebrationService.instance.celebrarInsigniaConquistada(
            insigniaId: 'madeira',
            insigniaName: 'Madeira',
            insigniaDescription: 'Configurou e ativou o módulo Dieta',
            assetPath: 'assets/gamification/insignias/diet/madeira.png',
          );
        }

        state = state.copyWith(
          gamification: effectiveGamification, 
          isLoading: false,
          isModuleActive: effectiveGamification.isModuleActive,
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
      final currentState = state.gamification ?? DietModuleState.initial();
      final earnedInsignias = List<String>.from(currentState.earnedInsignias);
      if (!earnedInsignias.any((i) => i.toLowerCase() == 'madeira')) {
        earnedInsignias.add('madeira');
      }
      final newState = currentState.copyWith(
        isModuleActive: true,
        earnedInsignias: earnedInsignias,
      );
      await _repository.saveDietState(newState);
      await DietCelebrationService.instance.celebrarInsigniaConquistada(
        insigniaId: 'madeira',
        insigniaName: 'Madeira',
        insigniaDescription: 'Configurou e ativou o módulo Dieta',
        assetPath: 'assets/gamification/insignias/diet/madeira.png',
      );
      await loadGamification();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deactivateModule() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final currentState = state.gamification ?? DietModuleState.initial();
      final newState = currentState.copyWith(isModuleActive: false);
      await _repository.saveDietState(newState);
      state = state.copyWith(isModuleActive: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetProgress() async {
    try {
      // Preserva a insígnia Madeira (incentivo para tentar novamente)
      final current = state.gamification;
      final hasMadeira = current?.earnedInsignias.any((i) => i.toLowerCase() == 'madeira') ?? false;
      
      await _repository.clearDietState();
      
      // Cria estado inicial preservando Madeira se existia
      final initialState = DietModuleState.initial();
      if (hasMadeira) {
        final stateWithMadeira = initialState.copyWith(
          earnedInsignias: ['madeira'],
        );
        await _repository.saveDietState(stateWithMadeira);
      } else {
        await _repository.saveDietState(initialState);
      }
      
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

/// Provider do Notifier
final dietGamificationNotifierProvider = StateNotifierProvider<
  DietGamificationNotifier,
  DietGamificationState
>((ref) {
  final repository = DietGamificationRepository.instance;
  return DietGamificationNotifier(repository);
});

/// Provider conveniente
final dietGamificationStateProvider = Provider<AsyncValue<DietGamificationState>>((ref) {
  final state = ref.watch(dietGamificationNotifierProvider);
  if (state.isLoading) return const AsyncValue.loading();
  if (state.error != null) return AsyncValue.error(state.error!, StackTrace.current);
  return AsyncValue.data(state);
});
