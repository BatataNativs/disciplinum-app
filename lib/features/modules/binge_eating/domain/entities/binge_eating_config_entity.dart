import 'package:objectbox/objectbox.dart';

@Entity()
class BingeEatingConfigEntity {
  @Id()
  int id = 0;

  @Unique()
  String userId;

  bool isEnabled = false;
  DateTime? blockedUntil;
  String? blockReason;
  int dailyLimitMinutes = 60;
  bool requirePassword = false;
  List<String> triggerFoods = [];
  List<String> copingStrategies = [];
  bool enableNotifications = true;
  int reminderHour = 20;
  int reminderMinute = 0;
  
  bool enableAppLock = false;
  List<String> monitoredApps = [];
  bool appLockRequirePassword = false;
  String appLockMessage = "Pare! Você está tentando acessar um app durante seu momento de controle alimentar.";
  int appLockCooldownMinutes = 5;
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  BingeEatingConfigEntity({
    required this.userId,
  });

  BingeEatingConfigEntity copyWith({
    String? userId,
    bool? isEnabled,
    DateTime? blockedUntil,
    String? blockReason,
    int? dailyLimitMinutes,
    bool? requirePassword,
    List<String>? triggerFoods,
    List<String>? copingStrategies,
    bool? enableNotifications,
    int? reminderHour,
    int? reminderMinute,
    bool? enableAppLock,
    List<String>? monitoredApps,
    bool? appLockRequirePassword,
    String? appLockMessage,
    int? appLockCooldownMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final entity = BingeEatingConfigEntity(userId: userId ?? this.userId);
    entity.isEnabled = isEnabled ?? this.isEnabled;
    entity.blockedUntil = blockedUntil ?? this.blockedUntil;
    entity.blockReason = blockReason ?? this.blockReason;
    entity.dailyLimitMinutes = dailyLimitMinutes ?? this.dailyLimitMinutes;
    entity.requirePassword = requirePassword ?? this.requirePassword;
    entity.triggerFoods = triggerFoods ?? this.triggerFoods;
    entity.copingStrategies = copingStrategies ?? this.copingStrategies;
    entity.enableNotifications = enableNotifications ?? this.enableNotifications;
    entity.reminderHour = reminderHour ?? this.reminderHour;
    entity.reminderMinute = reminderMinute ?? this.reminderMinute;
    entity.enableAppLock = enableAppLock ?? this.enableAppLock;
    entity.monitoredApps = monitoredApps ?? this.monitoredApps;
    entity.appLockRequirePassword = appLockRequirePassword ?? this.appLockRequirePassword;
    entity.appLockMessage = appLockMessage ?? this.appLockMessage;
    entity.appLockCooldownMinutes = appLockCooldownMinutes ?? this.appLockCooldownMinutes;
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    return entity;
  }

  void touch() {
    updatedAt = DateTime.now();
  }
}
