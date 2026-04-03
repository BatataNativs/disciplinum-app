import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/money_saving/domain/entities/money_saving_module_state.dart';
import 'package:disciplinum/features/modules/money_saving/gamification/domain/repositories/money_saving_gamification_repository.dart';
import 'package:disciplinum/core/di/providers.dart';

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
  bool get isActive => moduleState?.isActive ?? false;
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
      final updated = current.copyWith(isActive: true);
      await _repository.saveMoneySavingState(updated);
      await loadGamification(); // Recarrega para atualizar o estado
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deactivateModule() async {
    try {
      final current = state.moduleState;
      if (current != null) {
        final updated = current.copyWith(isActive: false);
        await _repository.saveMoneySavingState(updated);
        await loadGamification(); // Recarrega para atualizar o estado
      }
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
      await _repository.clearMoneySavingState();
      await loadGamification(); // Recarrega para atualizar o estado
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
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
