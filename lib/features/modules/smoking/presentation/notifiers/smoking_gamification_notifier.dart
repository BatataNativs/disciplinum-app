import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/core/logging/logger_service.dart';
import 'package:disciplinum/features/modules/smoking/domain/entities/smoking_module_state.dart';
import 'package:disciplinum/features/modules/smoking/gamification/domain/repositories/smoking_gamification_repository.dart';

/// Estado da gamificação do Smoking
class SmokingGamificationState {
  final SmokingModuleState? gamification;
  final bool isLoading;
  final String? error;
  final bool isModuleActive;

  const SmokingGamificationState({
    this.gamification,
    this.isLoading = false,
    this.error,
    this.isModuleActive = false,
  });

  SmokingGamificationState copyWith({
    SmokingModuleState? gamification,
    bool? isLoading,
    String? error,
    bool? isModuleActive,
  }) {
    return SmokingGamificationState(
      gamification: gamification ?? this.gamification,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isModuleActive: isModuleActive ?? this.isModuleActive,
    );
  }

  int get currentStreak => gamification?.consecutivePositiveDays ?? 0;
  int get disciplinumCount => gamification?.disciplinumCount ?? 0;
  List<String> get earnedInsignias => gamification?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => gamification?.earnedMedalhas ?? [];
  DateTime? get lastUpdated => gamification?.lastUpdated;
}

/// Notifier para gamificação do Smoking - Plugin independente
class SmokingGamificationNotifier extends StateNotifier<SmokingGamificationState> {
  final SmokingGamificationRepository _repository;

  SmokingGamificationNotifier(this._repository) 
      : super(const SmokingGamificationState());

  Future<void> loadGamification() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final gamification = await _repository.getSmokingState();
      if (gamification != null) {
        state = state.copyWith(
          gamification: gamification, 
          isLoading: false,
          isModuleActive: true, // Smoking sempre ativo quando tem dados
        );
      } else {
        // Cria estado inicial
        final initialState = SmokingModuleState.initial();
        await _repository.saveSmokingState(initialState);
        state = state.copyWith(
          gamification: initialState,
          isLoading: false,
          isModuleActive: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Ativa o módulo (cria estado inicial)
  Future<void> activateModule() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final initialState = SmokingModuleState.initial();
      await _repository.saveSmokingState(initialState);
      await _repository.syncWithSupabase(initialState);
      await loadGamification();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Desativa o módulo (limpa dados)
  Future<void> deactivateModule() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.clearSmokingState();
      state = state.copyWith(
        gamification: null,
        isModuleActive: false, 
        isLoading: false
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> resetProgress() async {
    try {
      // Preserva a insígnia Madeira (incentivo para tentar novamente)
      final current = state.gamification;
      final hasMadeira = current?.earnedInsignias.contains('Madeira') ?? false;
      
      await _repository.clearSmokingState();
      
      // Cria estado inicial preservando Madeira se existia
      final initialState = SmokingModuleState.initial();
      if (hasMadeira) {
        final stateWithMadeira = initialState.copyWith(
          earnedInsignias: ['Madeira'],
        );
        await _repository.saveSmokingState(stateWithMadeira);
        await _repository.syncWithSupabase(stateWithMadeira);
      } else {
        await _repository.saveSmokingState(initialState);
        await _repository.syncWithSupabase(initialState);
      }
      
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Salva mensagens customizadas para um nicho específico
  /// [nicheId] - ID do nicho (ex: 'motivation_phrases')
  /// [messages] - Lista de mensagens customizadas
  Future<void> setCustomMessages(String nicheId, List<String> messages) async {
    try {
      final current = state.gamification ?? SmokingModuleState.initial();
      
      // Cria cópia do mapa de mensagens customizadas
      final updatedMessages = Map<String, List<String>>.from(current.customMessages);
      updatedMessages[nicheId] = messages;
      
      final updated = current.copyWith(
        customMessages: updatedMessages,
      );
      
      await _repository.saveSmokingState(updated);
      await _repository.syncWithSupabase(updated);
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Define a mensagem principal customizada
  /// [message] - Mensagem principal
  Future<void> setCustomMainMessage(String message) async {
    try {
      final current = state.gamification ?? SmokingModuleState.initial();
      
      final updated = current.copyWith(
        customMainMessage: message,
      );
      
      await _repository.saveSmokingState(updated);
      await _repository.syncWithSupabase(updated);
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Recarrega sessões de monitoramento ativas
  /// Útil após atualizar mensagens ou configurações
  Future<void> reloadMonitoringSessions() async {
    try {
      // Força recarregamento do estado
      await loadGamification();
      
      LoggerService.instance.i('Sessões de monitoramento recarregadas');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

/// Provider do Notifier
final smokingGamificationNotifierProvider = StateNotifierProvider<
  SmokingGamificationNotifier,
  SmokingGamificationState
>((ref) {
  final repository = SmokingGamificationRepository.instance;
  return SmokingGamificationNotifier(repository);
});

/// Provider conveniente
final smokingGamificationStateProvider = Provider<AsyncValue<SmokingGamificationState>>((ref) {
  final state = ref.watch(smokingGamificationNotifierProvider);
  if (state.isLoading) return const AsyncValue.loading();
  if (state.error != null) return AsyncValue.error(state.error!, StackTrace.current);
  return AsyncValue.data(state);
});
