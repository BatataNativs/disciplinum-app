import 'package:isar/isar.dart';

part 'reading_gamification_entity.g.dart';

@collection
class ReadingGamificationEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String userId;

  // Streak tracking
  int currentStreak = 0;
  DateTime? lastReadingDate;
  DateTime? longestStreakStart;
  DateTime? longestStreakEnd;
  int longestStreakDays = 0;

  // Conquistas
  List<String> unlockedAchievements = [];
  DateTime? lastAchievementDate;

  // Estatísticas
  int totalBooksRead = 0;
  int totalPagesRead = 0;
  int totalReadingDays = 0;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  ReadingGamificationEntity({
    required this.userId,
  });

  ReadingGamificationEntity copyWith({
    String? userId,
    int? currentStreak,
    DateTime? lastReadingDate,
    DateTime? longestStreakStart,
    DateTime? longestStreakEnd,
    int? longestStreakDays,
    Set<String>? unlockedAchievements,
    DateTime? lastAchievementDate,
    int? totalBooksRead,
    int? totalPagesRead,
    int? totalReadingDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final entity = ReadingGamificationEntity(userId: userId ?? this.userId);
    entity.currentStreak = currentStreak ?? this.currentStreak;
    entity.lastReadingDate = lastReadingDate ?? this.lastReadingDate;
    entity.longestStreakStart = longestStreakStart ?? this.longestStreakStart;
    entity.longestStreakEnd = longestStreakEnd ?? this.longestStreakEnd;
    entity.longestStreakDays = longestStreakDays ?? this.longestStreakDays;
    entity.unlockedAchievements = unlockedAchievements?.toList() ?? entity.unlockedAchievements;
    entity.lastAchievementDate = lastAchievementDate ?? this.lastAchievementDate;
    entity.totalBooksRead = totalBooksRead ?? this.totalBooksRead;
    entity.totalPagesRead = totalPagesRead ?? this.totalPagesRead;
    entity.totalReadingDays = totalReadingDays ?? this.totalReadingDays;
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    return entity;
  }

  void touch() {
    updatedAt = DateTime.now();
  }

  /// Atualiza o streak após leitura
  void updateStreak(DateTime readingDate) {
    lastReadingDate = readingDate;
    
    // Verifica se é leitura consecutiva
    if (_isConsecutiveDay(readingDate)) {
      currentStreak++;
    } else {
      currentStreak = 1;
    }

    // Atualiza longest streak se necessário
    if (currentStreak > longestStreakDays) {
      longestStreakDays = currentStreak;
      longestStreakStart = _calculateStreakStart(readingDate, currentStreak);
      longestStreakEnd = readingDate;
    }

    touch();
  }

  /// Verifica se a data é consecutiva à última leitura
  bool _isConsecutiveDay(DateTime date) {
    if (lastReadingDate == null) return true;
    
    final difference = date.difference(lastReadingDate!).inDays;
    return difference == 1; // Exatamente 1 dia de diferença
  }

  /// Calcula a data de início do streak atual
  DateTime _calculateStreakStart(DateTime endDate, int streakDays) {
    return endDate.subtract(Duration(days: streakDays - 1));
  }

  /// Desbloqueia uma conquista
  void unlockAchievement(String achievementId) {
    if (!unlockedAchievements.contains(achievementId)) {
      unlockedAchievements.add(achievementId);
      lastAchievementDate = DateTime.now();
      touch();
    }
  }

  /// Verifica se uma conquista está desbloqueada
  bool hasAchievement(String achievementId) {
    return unlockedAchievements.contains(achievementId);
  }

  /// Adiciona páginas lidas
  void addPagesRead(int pages) {
    totalPagesRead += pages;
    touch();
  }

  /// Adiciona um livro lido
  void addBookRead() {
    totalBooksRead++;
    touch();
  }

  /// Adiciona um dia de leitura
  void addReadingDay() {
    totalReadingDays++;
    touch();
  }

  /// Verifica conquistas baseadas no streak
  List<String> checkStreakAchievements() {
    final achievements = <String>[];
    
    if (currentStreak >= 1 && !hasAchievement('first_day')) {
      achievements.add('first_day');
    }
    if (currentStreak >= 7 && !hasAchievement('week_warrior')) {
      achievements.add('week_warrior');
    }
    if (currentStreak >= 30 && !hasAchievement('month_master')) {
      achievements.add('month_master');
    }
    if (currentStreak >= 100 && !hasAchievement('century_reader')) {
      achievements.add('century_reader');
    }
    if (currentStreak >= 365 && !hasAchievement('year_legend')) {
      achievements.add('year_legend');
    }

    return achievements;
  }

  /// Verifica conquistas baseadas em estatísticas
  List<String> checkStatsAchievements() {
    final achievements = <String>[];
    
    if (totalBooksRead >= 1 && !hasAchievement('first_book')) {
      achievements.add('first_book');
    }
    if (totalBooksRead >= 10 && !hasAchievement('book_collector')) {
      achievements.add('book_collector');
    }
    if (totalBooksRead >= 50 && !hasAchievement('book_worm')) {
      achievements.add('book_worm');
    }
    if (totalPagesRead >= 100 && !hasAchievement('page_turner')) {
      achievements.add('page_turner');
    }
    if (totalPagesRead >= 1000 && !hasAchievement('page_master')) {
      achievements.add('page_master');
    }
    if (totalReadingDays >= 100 && !hasAchievement('dedicated_reader')) {
      achievements.add('dedicated_reader');
    }

    return achievements;
  }
}
