import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/focus/domain/entities/focus_module_state.dart';
import 'package:disciplinum/features/modules/focus/gamification/domain/repositories/focus_gamification_repository.dart';

/// Estado da gamificação do Focus
class FocusGamificationState {
  final FocusModuleState? gamification;
  final bool isLoading;
  final String? error;
  final bool isModuleActive;

  const FocusGamificationState({
    this.gamification,
    this.isLoading = false,
    this.error,
    this.isModuleActive = false,
  });

  FocusGamificationState copyWith({
    FocusModuleState? gamification,
    bool? isLoading,
    String? error,
    bool? isModuleActive,
  }) {
    return FocusGamificationState(
      gamification: gamification ?? this.gamification,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isModuleActive: isModuleActive ?? this.isModuleActive,
    );
  }

  int get currentStreak => gamification?.currentStreakDays ?? 0;
  int get totalFocusMinutes => gamification?.totalFocusMinutes ?? 0;
  List<String> get earnedInsignias => gamification?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => gamification?.earnedMedalhas ?? [];
  DateTime? get lastUpdated => gamification?.lastUpdated;
}

/// Notifier para gamificação do Focus - Plugin independente
class FocusGamificationNotifier extends StateNotifier<FocusGamificationState> {
  final FocusGamificationRepository _repository;

  FocusGamificationNotifier(this._repository)
      : super(const FocusGamificationState()) {
    // Carrega dados automaticamente na inicialização
    loadGamification();
  }

  Future<void> loadGamification() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gamification = await _repository.getFocusState();
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
      final currentState = state.gamification ?? FocusModuleState.initial();
      // Concede insígnia Madeira se ainda não tiver
      final earnedInsignias = List<String>.from(currentState.earnedInsignias);
      if (!earnedInsignias.contains('madeira')) {
        earnedInsignias.add('madeira');
      }
      final newState = currentState.copyWith(
        isModuleActive: true,
        earnedInsignias: earnedInsignias,
      );
      await _repository.saveFocusState(newState);
      await _repository.syncWithSupabase(newState);
      await loadGamification();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deactivateModule() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final currentState = state.gamification ?? FocusModuleState.initial();
      final newState = currentState.copyWith(isModuleActive: false);
      await _repository.saveFocusState(newState);
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
      final hasMadeira = current?.earnedInsignias.contains('madeira') ?? false;
      
      await _repository.clearFocusState();
      
      // Cria estado inicial preservando Madeira se existia
      final initialState = FocusModuleState.initial();
      if (hasMadeira) {
        final stateWithMadeira = initialState.copyWith(
          earnedInsignias: ['madeira'],
        );
        await _repository.saveFocusState(stateWithMadeira);
        await _repository.syncWithSupabase(stateWithMadeira);
      } else {
        await _repository.saveFocusState(initialState);
        await _repository.syncWithSupabase(initialState);
      }
      
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Registra uma sessão de foco completada
  /// [minutes] - minutos focados
  /// Retorna true se uma conquista foi desbloqueada
  Future<bool> recordFocusSession(int minutes) async {
    if (minutes <= 0) return false;
    
    try {
      final current = state.gamification ?? FocusModuleState.initial();
      
      // Atualiza estatísticas
      final newTotalMinutes = current.totalFocusMinutes + minutes;
      final newStreakDays = current.currentStreakDays + 1;
      
      // Verifica conquistas
      final unlockedInsignias = List<String>.from(current.earnedInsignias);
      final unlockedMedalhas = List<String>.from(current.earnedMedalhas);
      bool achievementUnlocked = false;
      
      // Insígnias por minutos focados
      if (newTotalMinutes >= 60 && !unlockedInsignias.contains('focus_60min')) {
        unlockedInsignias.add('focus_60min');
        achievementUnlocked = true;
      }
      if (newTotalMinutes >= 300 && !unlockedInsignias.contains('focus_5hours')) {
        unlockedInsignias.add('focus_5hours');
        achievementUnlocked = true;
      }
      if (newTotalMinutes >= 600 && !unlockedInsignias.contains('focus_10hours')) {
        unlockedInsignias.add('focus_10hours');
        achievementUnlocked = true;
      }
      
      // Medalhas por streak
      if (newStreakDays >= 7 && !unlockedMedalhas.contains('focus_week')) {
        unlockedMedalhas.add('focus_week');
        achievementUnlocked = true;
      }
      if (newStreakDays >= 30 && !unlockedMedalhas.contains('focus_month')) {
        unlockedMedalhas.add('focus_month');
        achievementUnlocked = true;
      }
      
      final updated = current.copyWith(
        totalFocusMinutes: newTotalMinutes,
        currentStreakDays: newStreakDays,
        sessionsCompleted: current.sessionsCompleted + 1,
        earnedInsignias: unlockedInsignias,
        earnedMedalhas: unlockedMedalhas,
      );
      
      await _repository.saveFocusState(updated);
      await _repository.syncWithSupabase(updated);
      await loadGamification();
      
      return achievementUnlocked;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

/// Provider do Notifier
final focusGamificationNotifierProvider = StateNotifierProvider<
  FocusGamificationNotifier,
  FocusGamificationState
>((ref) {
  final repository = FocusGamificationRepository.instance;
  return FocusGamificationNotifier(repository);
});

/// Provider conveniente
final focusGamificationStateProvider = Provider<AsyncValue<FocusGamificationState>>((ref) {
  final state = ref.watch(focusGamificationNotifierProvider);
  if (state.isLoading) return const AsyncValue.loading();
  if (state.error != null) return AsyncValue.error(state.error!, StackTrace.current);
  return AsyncValue.data(state);
});
