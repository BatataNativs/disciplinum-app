import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_module_state.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/repositories/money_saving_gamification_repository.dart';
import 'package:disciplinum/core/di/providers.dart';
import 'package:disciplinum/core/logging/logger_service.dart';

class MoneySavingGamificationState {
  final MoneySavingModuleState? moduleState;
  final bool isLoading;
  final String? error;

  const MoneySavingGamificationState({
    this.moduleState,
    this.isLoading = false,
    this.error,
  });

  MoneySavingGamificationState copyWith({
    MoneySavingModuleState? moduleState,
    bool? isLoading,
    String? error,
  }) {
    return MoneySavingGamificationState(
      moduleState: moduleState ?? this.moduleState,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  int get consecutiveDays => moduleState?.consecutiveDays ?? 0;
  int get bestStreak => moduleState?.bestStreak ?? 0;
  double get totalSavedAmount => moduleState?.totalSavedAmount ?? 0.0;
  int get disciplinumCount => moduleState?.disciplinumCount ?? 0;
  bool get isModuleActive => moduleState?.isModuleActive ?? false;
  DateTime? get lastSavingDate => moduleState?.lastSavingDate;
  List<String> get earnedInsignias => moduleState?.earnedInsignias ?? [];
  List<String> get earnedMedalhas => moduleState?.earnedMedalhas ?? [];
}

class MoneySavingGamificationNotifier extends StateNotifier<MoneySavingGamificationState> {
  final MoneySavingGamificationRepository _repository;
  final String userId;

  MoneySavingGamificationNotifier(this._repository, this.userId) : super(const MoneySavingGamificationState());

  Future<void> loadGamification() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final moduleState = await _repository.getMoneySavingState();
      state = state.copyWith(moduleState: moduleState, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> activateModule() async {
    try {
      final current = state.moduleState ?? MoneySavingModuleState();
      final updated = current.copyWith(isModuleActive: true);
      await _repository.saveMoneySavingState(updated);
      
      // Desbloqueia insígnia Madeira por ativar o módulo
      await unlockInsignia('Madeira');
      
      await loadGamification(); // Recarrega para atualizar o estado
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deactivateModule() async {
    try {
      final current = state.moduleState;
      if (current != null) {
        final updated = current.copyWith(isModuleActive: false);
        await _repository.saveMoneySavingState(updated);
        await loadGamification(); // Recarrega para atualizar o estado
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Atualiza a porcentagem de preenchimento do grid e desbloqueia insígnias correspondentes
  /// [percentage] - porcentagem de 0 a 100
  Future<void> updateGridPercentage(int percentage) async {
    if (percentage < 0 || percentage > 100) return;
    
    try {
      final current = state.moduleState ?? MoneySavingModuleState();
      
      final updated = current.copyWith(
        gridPercentage: percentage,
        lastSavingDate: DateTime.now(),
      );
      
      await _repository.saveMoneySavingState(updated);
      
      // Desbloqueia insígnias baseadas na porcentagem (conforme documentação)
      // Madeira - apenas por ativar o módulo (já dada no activateModule)
      
      if (percentage >= 5) {
        await unlockInsignia('Ferro');
      }
      if (percentage >= 10) {
        await unlockInsignia('Alumínio');
      }
      if (percentage >= 15) {
        await unlockInsignia('Latão');
      }
      if (percentage >= 20) {
        await unlockInsignia('Bronze');
      }
      if (percentage >= 40) {
        await unlockInsignia('Prata');
      }
      if (percentage >= 60) {
        await unlockInsignia('Ouro');
      }
      if (percentage >= 80) {
        await unlockInsignia('Diamante');
      }
      if (percentage >= 100) {
        await unlockInsignia('Disciplinum');
      }
      
      LoggerService.instance.i('Grid atualizado: $percentage%');
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateStreak(int consecutiveDays) async {
    try {
      final current = state.moduleState ?? MoneySavingModuleState();
      final updated = current.copyWith(
        consecutiveDays: consecutiveDays,
        bestStreak: consecutiveDays > current.bestStreak ? consecutiveDays : current.bestStreak,
        lastSavingDate: DateTime.now(),
      );
      await _repository.saveMoneySavingState(updated);
      await loadGamification(); // Recarrega para atualizar o estado
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addSavedAmount(double amount) async {
    try {
      final current = state.moduleState ?? MoneySavingModuleState();
      final updated = current.copyWith(
        totalSavedAmount: current.totalSavedAmount + amount,
        lastSavingDate: DateTime.now(),
      );
      await _repository.saveMoneySavingState(updated);
      await loadGamification(); // Recarrega para atualizar o estado
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unlockInsignia(String insigniaId) async {
    try {
      final current = state.moduleState ?? MoneySavingModuleState();
      final currentInsignias = current.earnedInsignias;
      if (!currentInsignias.contains(insigniaId)) {
        final newInsignias = [...currentInsignias, insigniaId];
        final updated = current.copyWith(
          earnedInsignias: newInsignias,
        );
        await _repository.saveMoneySavingState(updated);
        await loadGamification(); // Recarrega para atualizar o estado
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unlockMedalha(String medalhaId) async {
    try {
      final current = state.moduleState ?? MoneySavingModuleState();
      final currentMedalhas = current.earnedMedalhas;
      if (!currentMedalhas.contains(medalhaId)) {
        final newMedalhas = [...currentMedalhas, medalhaId];
        final updated = current.copyWith(
          earnedMedalhas: newMedalhas,
        );
        await _repository.saveMoneySavingState(updated);
        await loadGamification(); // Recarrega para atualizar o estado
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> resetProgress() async {
    try {
      // Preserva a insígnia Madeira (incentivo para tentar novamente)
      final current = state.moduleState;
      final hasMadeira = current?.earnedInsignias.contains('Madeira') ?? false;
      
      await _repository.clearMoneySavingState();
      
      // Cria estado inicial preservando Madeira se existia
      final initialState = MoneySavingModuleState.initial();
      if (hasMadeira) {
        final stateWithMadeira = initialState.copyWith(
          earnedInsignias: ['Madeira'],
        );
        await _repository.saveMoneySavingState(stateWithMadeira);
        await _repository.syncWithSupabase(stateWithMadeira);
      } else {
        await _repository.saveMoneySavingState(initialState);
        await _repository.syncWithSupabase(initialState);
      }
      
      await loadGamification();
      LoggerService.instance.i('Progresso resetado (Madeira preservada: $hasMadeira)');
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Completa um desafio de economia
  /// [challengeId] - ID do desafio
  /// [reward] - recompensa em valor economizado
  Future<void> completeChallenge(String challengeId, double reward) async {
    try {
      final current = state.moduleState ?? MoneySavingModuleState();
      
      // Atualiza total economizado com a recompensa do desafio
      final updated = current.copyWith(
        totalSavedAmount: current.totalSavedAmount + reward,
        lastSavingDate: DateTime.now(),
      );
      
      await _repository.saveMoneySavingState(updated);
      
      // Desbloqueia insígnia de desafio completado
      await unlockInsignia('challenge_$challengeId');
      
      LoggerService.instance.i('Desafio completado: $challengeId, recompensa: $reward');
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Completa uma meta de economia
  /// [goalAmount] - valor da meta atingida (apenas para logging)
  /// Desbloqueia insígnia Disciplinum e atualiza contador de desafios para medalhas
  Future<void> completeGoal(double goalAmount) async {
    try {
      final current = state.moduleState ?? MoneySavingModuleState();
      
      // Incrementa contador de desafios concluídos
      final completedChallenges = current.disciplinumCount + 1;
      
      final updated = current.copyWith(
        disciplinumCount: completedChallenges,
        lastSavingDate: DateTime.now(),
      );
      
      await _repository.saveMoneySavingState(updated);
      
      // Desbloqueia insígnia Disciplinum (100% do grid)
      await unlockInsignia('Disciplinum');
      
      // Desbloqueia medalha baseada em quantos desafios foram concluídos
      // 1 desafio = bronze, 2 = prata, 3 = ouro, 4 = diamante
      if (completedChallenges == 1) {
        await unlockMedalha('bronze');
      } else if (completedChallenges == 2) {
        await unlockMedalha('prata');
      } else if (completedChallenges == 3) {
        await unlockMedalha('ouro');
      } else if (completedChallenges == 4) {
        await unlockMedalha('diamante');
      }
      
      LoggerService.instance.i('Meta completada: $goalAmount, total desafios: $completedChallenges');
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() => state = state.copyWith(error: null);

  /// Processa eventos do módulo (compatibilidade com legado)
  Future<void> processModuleEvent(Map<String, dynamic> event) async {
    final eventType = event['type'] as String?;
    
    switch (eventType) {
      case 'daily_save':
        final amount = (event['amount'] as num?)?.toDouble() ?? 0.0;
        if (amount > 0) {
          await addSavedAmount(amount);
        }
        break;
      case 'goal_completed':
        final goalAmount = (event['goalAmount'] as num?)?.toDouble() ?? 0.0;
        if (goalAmount > 0) {
          await completeGoal(goalAmount);
        }
        break;
      case 'streak_update':
        // Streak já é atualizado automaticamente no addSavedAmount
        LoggerService.instance.i('Streak atualizado: ${event['streakDays']} dias');
        break;
      default:
        LoggerService.instance.d('Evento não reconhecido: $eventType');
    }
  }

  /// Limpa o estado da gamificação (usado ao desativar módulo)
  void clearGamification() {
    state = const MoneySavingGamificationState();
  }
}

// Providers
final moneySavingGamificationRepositoryProvider = Provider<MoneySavingGamificationRepository>((ref) {
  return MoneySavingGamificationRepository.instance;
});

final moneySavingGamificationNotifierProvider = StateNotifierProvider.family<MoneySavingGamificationNotifier, MoneySavingGamificationState, String>(
  (ref, userId) {
    final repository = ref.read(moneySavingGamificationRepositoryProvider);
    return MoneySavingGamificationNotifier(repository, userId);
  },
);

// Provider para o userId atual do usuário autenticado
final moneySavingCurrentUserIdProvider = Provider<String>((ref) {
  final authService = ref.watch(authServiceProvider);
  final currentUser = authService.currentUser;
  
  if (currentUser != null) {
    return currentUser.id;
  }
  
  // Fallback para usuário não autenticado (modo convidado)
  return 'guest_user';
});

// Provider conveniente para o estado atual
final moneySavingGamificationStateProvider = Provider<MoneySavingGamificationState>((ref) {
  final userId = ref.read(moneySavingCurrentUserIdProvider);
  return ref.watch(moneySavingGamificationNotifierProvider(userId));
});
