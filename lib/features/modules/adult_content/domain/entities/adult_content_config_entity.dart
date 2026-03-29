import 'package:isar/isar.dart';

part 'adult_content_config_entity.g.dart';

@collection
class AdultContentConfigEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  String userId;

  bool isEnabled = false;
  DateTime? blockedUntil;
  String? blockReason;
  int dailyLimitMinutes = 60;
  bool requirePassword = false;
  
  // AppLock Configuration
  bool enableAppLock = false;
  List<String> monitoredApps = []; // Package names para monitorar
  bool appLockRequirePassword = false;
  String appLockMessage = "Pare! Você está tentando acessar conteúdo adulto durante seu período de controle.";
  int appLockCooldownMinutes = 10; // Tempo mais longo para conteúdo adulto
  
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  AdultContentConfigEntity({
    required this.userId,
  });

  AdultContentConfigEntity copyWith({
    String? userId,
    bool? isEnabled,
    DateTime? blockedUntil,
    String? blockReason,
    int? dailyLimitMinutes,
    bool? requirePassword,
    bool? enableAppLock,
    List<String>? monitoredApps,
    bool? appLockRequirePassword,
    String? appLockMessage,
    int? appLockCooldownMinutes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final entity = AdultContentConfigEntity(userId: userId ?? this.userId);
    entity.isEnabled = isEnabled ?? this.isEnabled;
    entity.blockedUntil = blockedUntil ?? this.blockedUntil;
    entity.blockReason = blockReason ?? this.blockReason;
    entity.dailyLimitMinutes = dailyLimitMinutes ?? this.dailyLimitMinutes;
    entity.requirePassword = requirePassword ?? this.requirePassword;
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
