import 'package:isar/isar.dart';

part 'reading_config_entity.g.dart';

@collection
class ReadingConfigEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String userId;

  bool enableNotifications = true;
  int reminderHour = 20;
  int reminderMinute = 0;
  bool enableDailyReminder = true;
  bool enableStreakReminder = true;
  bool isModuleActive = false; // Estado de ativação do módulo
  
  // Estatísticas de streak
  int currentStreak = 0;
  DateTime? lastReadingDate;
  DateTime? longestStreakStart;
  DateTime? longestStreakEnd;
  int longestStreakDays = 0;
  
  // Metas
  int dailyPagesGoal = 20;
  int weeklyBooksGoal = 1;
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  ReadingConfigEntity({
    required this.userId,
    this.isModuleActive = false,
  });

  ReadingConfigEntity copyWith({
    String? userId,
    bool? enableNotifications,
    int? reminderHour,
    int? reminderMinute,
    bool? enableDailyReminder,
    bool? enableStreakReminder,
    bool? isModuleActive,
    int? currentStreak,
    DateTime? lastReadingDate,
    DateTime? longestStreakStart,
    DateTime? longestStreakEnd,
    int? longestStreakDays,
    int? dailyPagesGoal,
    int? weeklyBooksGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final entity = ReadingConfigEntity(userId: userId ?? this.userId);
    entity.enableNotifications = enableNotifications ?? this.enableNotifications;
    entity.reminderHour = reminderHour ?? this.reminderHour;
    entity.reminderMinute = reminderMinute ?? this.reminderMinute;
    entity.enableDailyReminder = enableDailyReminder ?? this.enableDailyReminder;
    entity.enableStreakReminder = enableStreakReminder ?? this.enableStreakReminder;
    entity.isModuleActive = isModuleActive ?? this.isModuleActive;
    entity.currentStreak = currentStreak ?? this.currentStreak;
    entity.lastReadingDate = lastReadingDate ?? this.lastReadingDate;
    entity.longestStreakStart = longestStreakStart ?? this.longestStreakStart;
    entity.longestStreakEnd = longestStreakEnd ?? this.longestStreakEnd;
    entity.longestStreakDays = longestStreakDays ?? this.longestStreakDays;
    entity.dailyPagesGoal = dailyPagesGoal ?? this.dailyPagesGoal;
    entity.weeklyBooksGoal = weeklyBooksGoal ?? this.weeklyBooksGoal;
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    return entity;
  }

  void touch() {
    updatedAt = DateTime.now();
  }

  /// Verifica se o streak atual é o mais longo
  void updateLongestStreak() {
    if (currentStreak > longestStreakDays) {
      longestStreakDays = currentStreak;
      // Não temos data de início precisa ser calculada externamente
    }
  }
}
