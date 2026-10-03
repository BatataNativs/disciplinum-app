import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/procrastination/domain/entities/procrastination_module_state.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/domain/repositories/procrastination_gamification_repository.dart';
import 'package:disciplinum/features/modules/procrastination/gamification/domain/services/procrastination_celebration_service.dart';

/// Estado da gamificação do Procrastination
class ProcrastinationGamificationState {
  final ProcrastinationModuleState? gamification;
  final bool isLoading;
  final String? error;
  final bool isModuleActive;

  const ProcrastinationGamificationState({
    this.gamification,
    this.isLoading = false,
    this.error,
    this.isModuleActive = false,
  });

  ProcrastinationGamificationState copyWith({
    ProcrastinationModuleState? gamification,
    bool? isLoading,
    String? error,
    bool? isModuleActive,
  }) {
    return ProcrastinationGamificationState(
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

/// Notifier para gamificação do Procrastination - Plugin independente
class ProcrastinationGamificationNotifier extends StateNotifier<ProcrastinationGamificationState> {
  final ProcrastinationGamificationRepository _repository;

  ProcrastinationGamificationNotifier(this._repository) 
      : super(const ProcrastinationGamificationState());

  Future<void> loadGamification() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gamification = await _repository.getProcrastinationState();
      if (gamification != null) {
        ProcrastinationModuleState effectiveGamification = gamification;
        if (effectiveGamification.isModuleActive && !effectiveGamification.earnedInsignias.any((i) => i.toLowerCase() == 'madeira')) {
          effectiveGamification = effectiveGamification.copyWith(
            earnedInsignias: [...effectiveGamification.earnedInsignias, 'madeira'],
          );
          await _repository.saveProcrastinationState(effectiveGamification);
          ProcrastinationCelebrationService.instance.celebrarInsigniaConquistada(
            insigniaId: 'madeira',
            insigniaName: 'Madeira',
            insigniaDescription: 'Configurou e ativou o módulo Produtividade',
            assetPath: 'assets/gamification/insignias/procrastination/madeira.png',
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
      final currentState = state.gamification ?? ProcrastinationModuleState.initial();
      // Concede insígnia Madeira se ainda não tiver
      final earnedInsignias = List<String>.from(currentState.earnedInsignias);
      if (!earnedInsignias.any((i) => i.toLowerCase() == 'madeira')) {
        earnedInsignias.add('madeira');
      }
      final newState = currentState.copyWith(
        isModuleActive: true,
        earnedInsignias: earnedInsignias,
      );
      await _repository.saveProcrastinationState(newState);
      await ProcrastinationCelebrationService.instance.celebrarInsigniaConquistada(
        insigniaId: 'madeira',
        insigniaName: 'Madeira',
        insigniaDescription: 'Configurou e ativou o módulo Produtividade',
        assetPath: 'assets/gamification/insignias/procrastination/madeira.png',
      );
      await loadGamification();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deactivateModule() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final currentState = state.gamification ?? ProcrastinationModuleState.initial();
      final newState = currentState.copyWith(isModuleActive: false);
      await _repository.saveProcrastinationState(newState);
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
      
      await _repository.clearProcrastinationState();
      
      // Cria estado inicial preservando Madeira se existia
      final initialState = ProcrastinationModuleState.initial();
      if (hasMadeira) {
        final stateWithMadeira = initialState.copyWith(
          earnedInsignias: ['madeira'],
        );
        await _repository.saveProcrastinationState(stateWithMadeira);
      } else {
        await _repository.saveProcrastinationState(initialState);
      }
      
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

/// Provider do Notifier
final procrastinationGamificationNotifierProvider = StateNotifierProvider<
  ProcrastinationGamificationNotifier,
  ProcrastinationGamificationState
>((ref) {
  final repository = ProcrastinationGamificationRepository.instance;
  return ProcrastinationGamificationNotifier(repository);
});

/// Provider conveniente
final procrastinationGamificationStateProvider = Provider<AsyncValue<ProcrastinationGamificationState>>((ref) {
  final state = ref.watch(procrastinationGamificationNotifierProvider);
  if (state.isLoading) return const AsyncValue.loading();
  if (state.error != null) return AsyncValue.error(state.error!, StackTrace.current);
  return AsyncValue.data(state);
});
