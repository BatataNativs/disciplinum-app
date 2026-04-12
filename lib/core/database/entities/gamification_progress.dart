import 'package:objectbox/objectbox.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

@Entity()
class GamificationProgress {
  @Id()
  int id = 0;

  final String userId;
  final int nicheId;
  final int currentStreak;
  final int bestStreak;
  final DateTime lastActivityDate;
  final String? unlockedAchievements;
  final String? currentMedal;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? additionalData;

  GamificationProgress({
    required this.userId,
    required this.nicheId,
    required this.currentStreak,
    required this.bestStreak,
    required this.lastActivityDate,
    this.unlockedAchievements,
    this.currentMedal,
    required this.createdAt,
    required this.updatedAt,
    this.additionalData,
  });

  factory GamificationProgress.create({
    required String userId,
    required int nicheId,
  }) {
    final now = DateTime.now();
    return GamificationProgress(
      userId: userId,
      nicheId: nicheId,
      currentStreak: 0,
      bestStreak: 0,
      lastActivityDate: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  NicheId get niche => NicheId.values.firstWhere(
        (id) => id.id == nicheId,
        orElse: () => NicheId.reading,
      );

  bool get isNewDay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActivity = DateTime(
      lastActivityDate.year,
      lastActivityDate.month,
      lastActivityDate.day,
    );
    return today.isAfter(lastActivity);
  }

  bool get isStreakBroken {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final lastActivity = DateTime(
      lastActivityDate.year,
      lastActivityDate.month,
      lastActivityDate.day,
    );
    final yesterdayDate = DateTime(
      yesterday.year,
      yesterday.month,
      yesterday.day,
    );
    return lastActivity.isBefore(yesterdayDate);
  }

  GamificationProgress copyWith({
    String? userId,
    int? nicheId,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastActivityDate,
    String? unlockedAchievements,
    String? currentMedal,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? additionalData,
  }) {
    return GamificationProgress(
      userId: userId ?? this.userId,
      nicheId: nicheId ?? this.nicheId,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      currentMedal: currentMedal ?? this.currentMedal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  GamificationProgress updateStreak() {
    final now = DateTime.now();
    final newStreak = isStreakBroken ? 1 : currentStreak + 1;
    final newBestStreak = newStreak > bestStreak ? newStreak : bestStreak;
    return copyWith(
      currentStreak: newStreak,
      bestStreak: newBestStreak,
      lastActivityDate: now,
      updatedAt: now,
    );
  }

  GamificationProgress updateMedal(String newMedal) {
    return copyWith(
      currentMedal: newMedal,
      updatedAt: DateTime.now(),
    );
  }
}
