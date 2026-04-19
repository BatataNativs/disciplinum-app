import 'package:objectbox/objectbox.dart';

@Entity()
class ProcrastinationConfigEntity {
  @Id()
  int id = 0;

  @Unique()
  String userId;

  bool isModuleActive = false;
  int dailyFocusMinutes = 120;
  bool enableNotifications = true;
  int reminderHour = 9;
  int reminderMinute = 0;
  
  int streakDays = 0;
  DateTime? lastFocusDate;
  int totalFocusMinutes = 0;
  int longestFocusSession = 0;
  
  bool enableAppBlocking = false;
  List<String> blockedApps = [];
  int blockDurationMinutes = 30;
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  ProcrastinationConfigEntity({
    required this.userId,
  });

  ProcrastinationConfigEntity copyWith({
    String? userId,
    bool? isModuleActive,
    int? dailyFocusMinutes,
    bool? enableNotifications,
    int? reminderHour,
    int? reminderMinute,
    int? streakDays,
    DateTime? lastFocusDate,
    int? totalFocusMinutes,
    int? longestFocusSession,
    bool? enableAppBlocking,
    List<String>? blockedApps,
    int? blockDurationMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final entity = ProcrastinationConfigEntity(userId: userId ?? this.userId);
    entity.isModuleActive = isModuleActive ?? this.isModuleActive;
    entity.dailyFocusMinutes = dailyFocusMinutes ?? this.dailyFocusMinutes;
    entity.enableNotifications = enableNotifications ?? this.enableNotifications;
    entity.reminderHour = reminderHour ?? this.reminderHour;
    entity.reminderMinute = reminderMinute ?? this.reminderMinute;
    entity.streakDays = streakDays ?? this.streakDays;
    entity.lastFocusDate = lastFocusDate ?? this.lastFocusDate;
    entity.totalFocusMinutes = totalFocusMinutes ?? this.totalFocusMinutes;
    entity.longestFocusSession = longestFocusSession ?? this.longestFocusSession;
    entity.enableAppBlocking = enableAppBlocking ?? this.enableAppBlocking;
    entity.blockedApps = blockedApps ?? this.blockedApps;
    entity.blockDurationMinutes = blockDurationMinutes ?? this.blockDurationMinutes;
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    return entity;
  }

  void touch() {
    updatedAt = DateTime.now();
  }
}
