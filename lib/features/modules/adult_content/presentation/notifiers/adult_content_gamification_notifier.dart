import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/adult_content/domain/entities/adult_content_module_state.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/repositories/adult_content_gamification_repository.dart';
import 'package:disciplinum/features/modules/adult_content/gamification/domain/services/adult_content_celebration_service.dart';

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
        AdultContentModuleState effectiveGamification = gamification;
        if (effectiveGamification.isModuleActive && !effectiveGamification.earnedInsignias.any((i) => i.toLowerCase() == 'madeira')) {
          effectiveGamification = effectiveGamification.copyWith(
            earnedInsignias: [...effectiveGamification.earnedInsignias, 'madeira'],
          );
          await _repository.saveAdultContentState(effectiveGamification);
          AdultContentCelebrationService.instance.celebrarInsigniaConquistada(
            insigniaId: 'madeira',
            insigniaName: 'Madeira',
            insigniaDescription: 'Configurou e ativou o módulo Jejum 18+',
            assetPath: 'assets/gamification/insignias/adult_content/madeira.png',
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
      final currentState = state.gamification ?? AdultContentModuleState.initial();
      // Concede insígnia Madeira se ainda não tiver
      final earnedInsignias = List<String>.from(currentState.earnedInsignias);
      if (!earnedInsignias.any((i) => i.toLowerCase() == 'madeira')) {
        earnedInsignias.add('madeira');
      }
      final newState = currentState.copyWith(
        isModuleActive: true,
        earnedInsignias: earnedInsignias,
      );
      await _repository.saveAdultContentState(newState);
      await AdultContentCelebrationService.instance.celebrarInsigniaConquistada(
        insigniaId: 'madeira',
        insigniaName: 'Madeira',
        insigniaDescription: 'Configurou e ativou o módulo Jejum 18+',
        assetPath: 'assets/gamification/insignias/adult_content/madeira.png',
      );
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
      
      await _repository.clearAdultContentState();
      
      // Cria estado inicial preservando Madeira se existia
      final initialState = AdultContentModuleState.initial();
      if (hasMadeira) {
        final stateWithMadeira = initialState.copyWith(
          earnedInsignias: ['madeira'],
        );
        await _repository.saveAdultContentState(stateWithMadeira);
      } else {
        await _repository.saveAdultContentState(initialState);
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
