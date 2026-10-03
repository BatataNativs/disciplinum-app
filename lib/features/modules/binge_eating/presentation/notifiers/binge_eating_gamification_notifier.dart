import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/binge_eating/domain/entities/binge_eating_module_state.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/repositories/binge_eating_gamification_repository.dart';
import 'package:disciplinum/features/modules/binge_eating/gamification/domain/services/binge_eating_celebration_service.dart';

/// Estado da gamificação do Binge Eating
class BingeEatingGamificationState {
  final BingeEatingModuleState? gamification;
  final bool isLoading;
  final String? error;
  final bool isModuleActive;

  const BingeEatingGamificationState({
    this.gamification,
    this.isLoading = false,
    this.error,
    this.isModuleActive = false,
  });

  BingeEatingGamificationState copyWith({
    BingeEatingModuleState? gamification,
    bool? isLoading,
    String? error,
    bool? isModuleActive,
  }) {
    return BingeEatingGamificationState(
      gamification: gamification ?? this.gamification,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isModuleActive: isModuleActive ?? this.isModuleActive,
    );
  }

  // Getters para facilitar acesso
  int get currentStreak => gamification?.consecutivePositiveDays ?? 0;
  int get disciplinumCount => gamification?.disciplinumCount ?? 0;
  List<String> get earnedInsignias => gamification?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => gamification?.earnedMedalhas ?? [];
  DateTime? get lastUpdated => gamification?.lastUpdated;
}

/// Notifier para gamificação do Binge Eating - Plugin independente
class BingeEatingGamificationNotifier extends StateNotifier<BingeEatingGamificationState> {
  final BingeEatingGamificationRepository _repository;

  BingeEatingGamificationNotifier(this._repository) 
      : super(const BingeEatingGamificationState());

  /// Inicializa e carrega gamificação
  Future<void> loadGamification() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final gamification = await _repository.getBingeEatingState();
      if (gamification != null) {
        BingeEatingModuleState effectiveGamification = gamification;
        if (effectiveGamification.isModuleActive && !effectiveGamification.earnedInsignias.any((i) => i.toLowerCase() == 'madeira')) {
          effectiveGamification = effectiveGamification.copyWith(
            earnedInsignias: [...effectiveGamification.earnedInsignias, 'madeira'],
          );
          await _repository.saveBingeEatingState(effectiveGamification);
          BingeEatingCelebrationService.instance.celebrarInsigniaConquistada(
            insigniaId: 'madeira',
            insigniaName: 'Madeira',
            insigniaDescription: 'Configurou e ativou o módulo Compulsão Alimentar',
            assetPath: 'assets/gamification/insignias/binge_eating/madeira.png',
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

  /// Ativa o módulo
  Future<void> activateModule() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final currentState = state.gamification ?? BingeEatingModuleState.initial();
      final earnedInsignias = List<String>.from(currentState.earnedInsignias);
      if (!earnedInsignias.any((i) => i.toLowerCase() == 'madeira')) {
        earnedInsignias.add('madeira');
      }
      final newState = currentState.copyWith(
        isModuleActive: true,
        earnedInsignias: earnedInsignias,
      );
      
      await _repository.saveBingeEatingState(newState);
      await BingeEatingCelebrationService.instance.celebrarInsigniaConquistada(
        insigniaId: 'madeira',
        insigniaName: 'Madeira',
        insigniaDescription: 'Configurou e ativou o módulo Compulsão Alimentar',
        assetPath: 'assets/gamification/insignias/binge_eating/madeira.png',
      );
      
      await loadGamification();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Desativa o módulo
  Future<void> deactivateModule() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final currentState = state.gamification ?? BingeEatingModuleState.initial();
      final newState = currentState.copyWith(isModuleActive: false);
      
      await _repository.saveBingeEatingState(newState);
      
      state = state.copyWith(isModuleActive: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Reseta progresso do módulo
  Future<void> resetProgress() async {
    try {
      // Preserva a insígnia Madeira (incentivo para tentar novamente)
      final current = state.gamification;
      final hasMadeira = current?.earnedInsignias.any((i) => i.toLowerCase() == 'madeira') ?? false;
      
      await _repository.clearBingeEatingState();
      
      // Cria estado inicial preservando Madeira se existia
      final initialState = BingeEatingModuleState.initial();
      if (hasMadeira) {
        final stateWithMadeira = initialState.copyWith(
          earnedInsignias: ['madeira'],
        );
        await _repository.saveBingeEatingState(stateWithMadeira);
      } else {
        await _repository.saveBingeEatingState(initialState);
      }
      
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Limpa erro
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider do Notifier - Plugin independente
final bingeEatingGamificationNotifierProvider = StateNotifierProvider<
  BingeEatingGamificationNotifier,
  BingeEatingGamificationState
>((ref) {
  final repository = BingeEatingGamificationRepository.instance;
  return BingeEatingGamificationNotifier(repository);
});

/// Provider conveniente para acessar estado atual
final bingeEatingGamificationStateProvider = Provider<AsyncValue<BingeEatingGamificationState>>((ref) {
  final state = ref.watch(bingeEatingGamificationNotifierProvider);
  
  if (state.isLoading) {
    return const AsyncValue.loading();
  }
  
  if (state.error != null) {
    return AsyncValue.error(state.error!, StackTrace.current);
  }
  
  return AsyncValue.data(state);
});
