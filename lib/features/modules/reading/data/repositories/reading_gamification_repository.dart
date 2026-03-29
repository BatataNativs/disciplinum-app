import 'package:disciplinum/features/modules/reading/domain/entities/reading_gamification_entity.dart';
import 'package:disciplinum/core/database/isar_service.dart';

class ReadingGamificationRepository {
  static ReadingGamificationRepository? _instance;
  static ReadingGamificationRepository get instance => 
      _instance ??= ReadingGamificationRepository._internal();
  
  ReadingGamificationRepository._internal();

  Future<ReadingGamificationEntity?> getGamification(String userId) async {
    final isar = IsarService.instance.database;
    return await isar.readingGamificationEntitys.get(1); // ID fixo como outros módulos
  }

  Future<ReadingGamificationEntity> getOrCreateGamification(String userId) async {
    final existing = await getGamification(userId);
    if (existing != null) return existing;

    final newGamification = ReadingGamificationEntity(userId: userId);
    newGamification.id = 1; // ID fixo
    final isar = IsarService.instance.database;
    await isar.writeTxn(() async {
      await isar.readingGamificationEntitys.put(newGamification);
    });
    return newGamification;
  }

  Future<void> updateGamification(ReadingGamificationEntity gamification) async {
    gamification.id = 1; // Garante ID fixo
    final isar = IsarService.instance.database;
    await isar.writeTxn(() async {
      await isar.readingGamificationEntitys.put(gamification);
    });
  }

  Future<void> updateStreak(String userId, DateTime readingDate) async {
    final gamification = await getOrCreateGamification(userId);
    gamification.updateStreak(readingDate);
    await updateGamification(gamification);
  }

  Future<void> unlockAchievement(String userId, String achievementId) async {
    final gamification = await getOrCreateGamification(userId);
    gamification.unlockAchievement(achievementId);
    await updateGamification(gamification);
  }

  Future<void> addPagesRead(String userId, int pages) async {
    final gamification = await getOrCreateGamification(userId);
    gamification.addPagesRead(pages);
    await updateGamification(gamification);
  }

  Future<void> addBookRead(String userId) async {
    final gamification = await getOrCreateGamification(userId);
    gamification.addBookRead();
    await updateGamification(gamification);
  }

  Future<void> addReadingDay(String userId) async {
    final gamification = await getOrCreateGamification(userId);
    gamification.addReadingDay();
    await updateGamification(gamification);
  }

  Future<List<String>> checkAndUnlockAchievements(String userId) async {
    final gamification = await getOrCreateGamification(userId);
    
    final streakAchievements = gamification.checkStreakAchievements();
    final statsAchievements = gamification.checkStatsAchievements();
    
    final allAchievements = [...streakAchievements, ...statsAchievements];
    
    for (final achievement in allAchievements) {
      if (!gamification.hasAchievement(achievement)) {
        gamification.unlockAchievement(achievement);
      }
    }
    
    await updateGamification(gamification);
    return allAchievements;
  }

  Future<bool> hasAchievement(String userId, String achievementId) async {
    final gamification = await getGamification(userId);
    return gamification?.hasAchievement(achievementId) ?? false;
  }

  Future<void> deleteGamification(String userId) async {
    final isar = IsarService.instance.database;
    await isar.writeTxn(() async {
      await isar.readingGamificationEntitys.clear();
    });
  }
}
