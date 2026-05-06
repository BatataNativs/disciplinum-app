import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/reading/gamification/domain/entities/reading_gamification_entity.dart';
import 'package:disciplinum/features/modules/reading/gamification/data/repositories/reading_gamification_repository.dart'
    as decentralized;

class ReadingGamificationState {
  final ReadingGamificationEntity? gamification;
  final bool isLoading;
  final String? error;

  const ReadingGamificationState({
    this.gamification,
    this.isLoading = false,
    this.error,
  });

  ReadingGamificationState copyWith({
    ReadingGamificationEntity? gamification,
    bool? isLoading,
    String? error,
  }) {
    return ReadingGamificationState(
      gamification: gamification ?? this.gamification,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  int get consecutiveDays => gamification?.consecutiveDays ?? 0;
  int get currentStreak => consecutiveDays;
  List<String> get earnedInsigniasList => gamification?.earnedInsigniasList ?? [];
  List<String> get earnedMedalhasList => gamification?.earnedMedalhasList ?? [];
  DateTime? get lastReadingDate => gamification?.lastReadingDate;
}

class ReadingGamificationNotifier extends StateNotifier<ReadingGamificationState> {
  final decentralized.ReadingGamificationRepository _repository;

  ReadingGamificationNotifier(this._repository) : super(const ReadingGamificationState());

  Future<void> loadGamification() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final gamification = await _repository.getReadingState();
      state = state.copyWith(gamification: gamification, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveState(ReadingGamificationEntity entity) async {
    try {
      await _repository.saveReadingState(entity);
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearGamification() {
    state = const ReadingGamificationState();
  }

  /// Reseta progresso do módulo preservando insígnia Madeira
  Future<void> resetProgress() async {
    try {
      final current = state.gamification;
      final hasMadeira = current?.earnedInsigniasList.contains('Madeira') ?? false;

      final initialState = ReadingGamificationEntity();
      initialState.id = 1;
      if (hasMadeira) {
        initialState.earnedInsigniasList = ['Madeira'];
      }

      await _repository.saveReadingState(initialState);
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Ativa o módulo e concede a insígnia Madeira
  Future<void> activateModule() async {
    try {
      final current = state.gamification;

      // Cria novo estado ou atualiza existente
      final updatedState = current ?? ReadingGamificationEntity();
      updatedState.id = 1;
      updatedState.isModuleActive = true;

      // Concede insígnia Madeira se ainda não tiver
      final earnedInsignias = updatedState.earnedInsigniasList;
      if (!earnedInsignias.contains('madeira')) {
        earnedInsignias.add('madeira');
        updatedState.earnedInsigniasList = earnedInsignias;
      }

      await _repository.saveReadingState(updatedState);
      await loadGamification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Providers
final readingGamificationRepositoryProvider = Provider<decentralized.ReadingGamificationRepository>((ref) {
  return decentralized.ReadingGamificationRepository.instance;
});

final readingGamificationNotifierProvider = StateNotifierProvider<ReadingGamificationNotifier, ReadingGamificationState>(
  (ref) {
    final repository = ref.read(readingGamificationRepositoryProvider);
    return ReadingGamificationNotifier(repository);
  },
);

// Provider conveniente para o estado atual
final readingGamificationStateProvider = Provider<ReadingGamificationState>((ref) {
  return ref.watch(readingGamificationNotifierProvider);
});

/// Provider para o streak do Reading
final readingStreakProvider = Provider<int>((ref) {
  final state = ref.watch(readingGamificationNotifierProvider);
  return state.currentStreak;
});

/// Provider para insígnias conquistadas
final readingInsigniasProvider = Provider<List<String>>((ref) {
  final state = ref.watch(readingGamificationNotifierProvider);
  return state.earnedInsigniasList;
});

/// Provider para medalhas conquistadas
final readingMedalhasProvider = Provider<List<String>>((ref) {
  final state = ref.watch(readingGamificationNotifierProvider);
  return state.earnedMedalhasList;
});

/// Provider para contagem de Disciplinum
final readingDisciplinumCountProvider = Provider<int>((ref) {
  final state = ref.watch(readingGamificationNotifierProvider);
  return state.earnedInsigniasList.where((i) => i == 'disciplinum').length;
});
