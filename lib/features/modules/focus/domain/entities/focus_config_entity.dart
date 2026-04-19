import 'package:objectbox/objectbox.dart';

@Entity()
class FocusConfigEntity {
  @Id()
  int id = 0;

  @Unique()
  String userId;

  bool isModuleActive = false;
  bool enableNotifications = true;
  int dailyGoalMinutes = 120;
  int reminderHour = 9;
  int reminderMinute = 0;
  
  int streakDays = 0;
  DateTime? lastFocusDate;
  int totalFocusMinutes = 0;
  int longestFocusSession = 0;
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  FocusConfigEntity({
    required this.userId,
  });

  FocusConfigEntity copyWith({
    String? userId,
    bool? isModuleActive,
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
    entity.id = id;
    entity.isModuleActive = isModuleActive ?? this.isModuleActive;
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
