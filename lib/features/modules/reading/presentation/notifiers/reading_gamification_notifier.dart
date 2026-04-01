import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:disciplinum/features/modules/reading/domain/entities/reading_gamification_entity.dart';
import 'package:disciplinum/features/modules/reading/data/repositories/reading_gamification_repository.dart';
import 'package:disciplinum/core/di/providers.dart';

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

  int get currentStreak => gamification?.currentStreak ?? 0;
  int get longestStreakDays => gamification?.longestStreakDays ?? 0;
  int get totalBooksRead => gamification?.totalBooksRead ?? 0;
  int get totalPagesRead => gamification?.totalPagesRead ?? 0;
  int get totalReadingDays => gamification?.totalReadingDays ?? 0;
  Set<String> get unlockedAchievements => gamification?.unlockedAchievements.toSet() ?? {};
  DateTime? get lastReadingDate => gamification?.lastReadingDate;
}

class ReadingGamificationNotifier extends StateNotifier<ReadingGamificationState> {
  final ReadingGamificationRepository _repository;
  final String userId;

  ReadingGamificationNotifier(this._repository, this.userId) : super(const ReadingGamificationState());

  Future<void> loadGamification() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final gamification = await _repository.getOrCreateGamification(userId);
      state = state.copyWith(gamification: gamification, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateStreak(DateTime readingDate) async {
    try {
      await _repository.updateStreak(userId, readingDate);
      await loadGamification(); // Recarrega para atualizar o estado
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unlockAchievement(String achievementId) async {
    try {
      await _repository.unlockAchievement(userId, achievementId);
      await loadGamification(); // Recarrega para atualizar o estado
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addPagesRead(int pages) async {
    try {
      await _repository.addPagesRead(userId, pages);
      await loadGamification(); // Recarrega para atualizar o estado
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addBookRead() async {
    try {
      await _repository.addBookRead(userId);
      await loadGamification(); // Recarrega para atualizar o estado
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addReadingDay() async {
    try {
      await _repository.addReadingDay(userId);
      await loadGamification(); // Recarrega para atualizar o estado
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<List<String>> checkAndUnlockAchievements() async {
    try {
      final achievements = await _repository.checkAndUnlockAchievements(userId);
      await loadGamification(); // Recarrega para atualizar o estado
      return achievements;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  Future<bool> hasAchievement(String achievementId) async {
    try {
      return await _repository.hasAchievement(userId, achievementId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearGamification() {
    state = const ReadingGamificationState();
  }
}

// Providers
final readingGamificationRepositoryProvider = Provider<ReadingGamificationRepository>((ref) {
  return ReadingGamificationRepository.instance;
});

final readingGamificationNotifierProvider = StateNotifierProvider.family<ReadingGamificationNotifier, ReadingGamificationState, String>(
  (ref, userId) {
    final repository = ref.read(readingGamificationRepositoryProvider);
    return ReadingGamificationNotifier(repository, userId);
  },
);

// Provider conveniente para o estado atual
final readingGamificationStateProvider = Provider<ReadingGamificationState>((ref) {
  final userId = ref.read(currentUserIdProvider);
  return ref.watch(readingGamificationNotifierProvider(userId));
});
