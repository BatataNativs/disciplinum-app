import 'package:isar/isar.dart';

part 'focus_config_entity.g.dart';

@collection
class FocusConfigEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String userId;

  bool isEnabled = false;
  bool enableNotifications = true;
  int dailyGoalMinutes = 120; // Meta diária em minutos
  int reminderHour = 9;
  int reminderMinute = 0;
  
  // Estatísticas
  int streakDays = 0;
  DateTime? lastFocusDate;
  int totalFocusMinutes = 0;
  int longestFocusSession = 0; // Em minutos
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  FocusConfigEntity({
    required this.userId,
  });

  FocusConfigEntity copyWith({
    String? userId,
    bool? isEnabled,
    bool? enableNotifications,
    int? dailyGoalMinutes,
    int? reminderHour,
    int? reminderMinute,
    int? streakDays,
    DateTime? lastFocusDate,
    int? totalFocusMinutes,
    int? longestFocusSession,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final entity = FocusConfigEntity(userId: userId ?? this.userId);
    entity.isEnabled = isEnabled ?? this.isEnabled;
    entity.enableNotifications = enableNotifications ?? this.enableNotifications;
    entity.dailyGoalMinutes = dailyGoalMinutes ?? this.dailyGoalMinutes;
    entity.reminderHour = reminderHour ?? this.reminderHour;
    entity.reminderMinute = reminderMinute ?? this.reminderMinute;
    entity.streakDays = streakDays ?? this.streakDays;
    entity.lastFocusDate = lastFocusDate ?? this.lastFocusDate;
    entity.totalFocusMinutes = totalFocusMinutes ?? this.totalFocusMinutes;
    entity.longestFocusSession = longestFocusSession ?? this.longestFocusSession;
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    return entity;
  }

  void touch() {
    updatedAt = DateTime.now();
  }
}
