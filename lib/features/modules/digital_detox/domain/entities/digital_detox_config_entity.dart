import 'package:objectbox/objectbox.dart';

/// Entidade de configuraÃ§Ã£o do mÃ³dulo Jejum Digital
/// Armazena todas as preferÃªncias e configuraÃ§Ãµes do usuÃ¡rio
@Entity()
class DigitalDetoxConfigEntity {
  @Id()
  int id = 0;

  @Unique()
  String userId;

  // Status do mÃ³dulo
  bool isModuleActive = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  // Apps monitorados
  List<String> monitoredApps = [];

  // === BLOQUEIO POR HORÃRIO (FASE 2) ===
  bool enableTimeWindow = false;
  String allowedStartTime = "08:00"; // HH:MM
  String allowedEndTime = "22:00"; // HH:MM
  bool blockOnWeekends = false;
  String? weekendAllowedStartTime; // HH:MM
  String? weekendAllowedEndTime; // HH:MM

  // === LIMITE DE TEMPO DIÃRIO (FASE 3) ===
  bool enableDailyLimit = false;
  int dailyLimitMinutes = 60; // minutos
  String limitType = "global"; // "perApp" | "global"
  int warnBeforeLimitMinutes = 5;

  // === NOTIFICAÃ‡ÃƒO PRÃ‰-DETOX (FASE 4) ===
  bool enablePreDetoxWarning = true;
  int preDetoxWarningMinutes = 5;
  String? preDetoxWarningMessage;

  // === HORAS CUMULATIVAS - ROLLOVER (FASE 6A) ===
  bool enableRolloverMinutes = false;
  int maxRolloverMinutes = 60;
  int rolloverExpirationDays = 7;

  // === LIMITE SEMANAL (FASE 6B) ===
  bool enableWeeklyLimit = false;
  int weeklyLimitMinutes = 540; // 9 horas
  String weeklyLimitStrategy = "flexible"; // "strict" | "flexible"

  // === SESSÃ•ES CONTROLADAS (FASE 6C) ===
  bool enableSessionMode = false;
  int sessionDurationMinutes = 10;
  int sessionCooldownHours = 2;
  int maxSessionsPerDay = 4;
  int sessionDailyLimitMinutes = 40;

  // === GAMIFICAÃ‡ÃƒO / STREAKS (FASE 4) ===
  int currentDisciplinedStreak = 0;
  int longestDisciplinedStreak = 0;
  int totalDisciplinedDays = 0;
  DateTime? lastDisciplinedDate;

  // === QUEBRA DE JEJUM (FASE 7) ===
  int fastingBreakDaysRequired = 7;
  int fastingBreakValidityDays = 30;

  DigitalDetoxConfigEntity({
    required this.userId,
  });

  DigitalDetoxConfigEntity copyWith({
    String? userId,
    bool? isModuleActive,
    List<String>? monitoredApps,
    bool? enableTimeWindow,
    String? allowedStartTime,
    String? allowedEndTime,
    bool? blockOnWeekends,
    String? weekendAllowedStartTime,
    String? weekendAllowedEndTime,
    bool? enableDailyLimit,
    int? dailyLimitMinutes,
    String? limitType,
    int? warnBeforeLimitMinutes,
    bool? enablePreDetoxWarning,
    int? preDetoxWarningMinutes,
    String? preDetoxWarningMessage,
    bool? enableRolloverMinutes,
    int? maxRolloverMinutes,
    int? rolloverExpirationDays,
    bool? enableWeeklyLimit,
    int? weeklyLimitMinutes,
    String? weeklyLimitStrategy,
    bool? enableSessionMode,
    int? sessionDurationMinutes,
    int? sessionCooldownHours,
    int? maxSessionsPerDay,
    int? sessionDailyLimitMinutes,
    int? currentDisciplinedStreak,
    int? longestDisciplinedStreak,
    int? totalDisciplinedDays,
    DateTime? lastDisciplinedDate,
    int? fastingBreakDaysRequired,
    int? fastingBreakValidityDays,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final entity = DigitalDetoxConfigEntity(userId: userId ?? this.userId);
    entity.id = id;
    entity.isModuleActive = isModuleActive ?? this.isModuleActive;
    entity.monitoredApps = monitoredApps ?? this.monitoredApps;
    entity.enableTimeWindow = enableTimeWindow ?? this.enableTimeWindow;
    entity.allowedStartTime = allowedStartTime ?? this.allowedStartTime;
    entity.allowedEndTime = allowedEndTime ?? this.allowedEndTime;
    entity.blockOnWeekends = blockOnWeekends ?? this.blockOnWeekends;
    entity.weekendAllowedStartTime = weekendAllowedStartTime ?? this.weekendAllowedStartTime;
    entity.weekendAllowedEndTime = weekendAllowedEndTime ?? this.weekendAllowedEndTime;
    entity.enableDailyLimit = enableDailyLimit ?? this.enableDailyLimit;
    entity.dailyLimitMinutes = dailyLimitMinutes ?? this.dailyLimitMinutes;
    entity.limitType = limitType ?? this.limitType;
    entity.warnBeforeLimitMinutes = warnBeforeLimitMinutes ?? this.warnBeforeLimitMinutes;
    entity.enablePreDetoxWarning = enablePreDetoxWarning ?? this.enablePreDetoxWarning;
    entity.preDetoxWarningMinutes = preDetoxWarningMinutes ?? this.preDetoxWarningMinutes;
    entity.preDetoxWarningMessage = preDetoxWarningMessage ?? this.preDetoxWarningMessage;
    entity.enableRolloverMinutes = enableRolloverMinutes ?? this.enableRolloverMinutes;
    entity.maxRolloverMinutes = maxRolloverMinutes ?? this.maxRolloverMinutes;
    entity.rolloverExpirationDays = rolloverExpirationDays ?? this.rolloverExpirationDays;
    entity.enableWeeklyLimit = enableWeeklyLimit ?? this.enableWeeklyLimit;
    entity.weeklyLimitMinutes = weeklyLimitMinutes ?? this.weeklyLimitMinutes;
    entity.weeklyLimitStrategy = weeklyLimitStrategy ?? this.weeklyLimitStrategy;
    entity.enableSessionMode = enableSessionMode ?? this.enableSessionMode;
    entity.sessionDurationMinutes = sessionDurationMinutes ?? this.sessionDurationMinutes;
    entity.sessionCooldownHours = sessionCooldownHours ?? this.sessionCooldownHours;
    entity.maxSessionsPerDay = maxSessionsPerDay ?? this.maxSessionsPerDay;
    entity.sessionDailyLimitMinutes = sessionDailyLimitMinutes ?? this.sessionDailyLimitMinutes;
    entity.currentDisciplinedStreak = currentDisciplinedStreak ?? this.currentDisciplinedStreak;
    entity.longestDisciplinedStreak = longestDisciplinedStreak ?? this.longestDisciplinedStreak;
    entity.totalDisciplinedDays = totalDisciplinedDays ?? this.totalDisciplinedDays;
    entity.lastDisciplinedDate = lastDisciplinedDate ?? this.lastDisciplinedDate;
    entity.fastingBreakDaysRequired = fastingBreakDaysRequired ?? this.fastingBreakDaysRequired;
    entity.fastingBreakValidityDays = fastingBreakValidityDays ?? this.fastingBreakValidityDays;
    entity.createdAt = createdAt ?? this.createdAt;
    entity.updatedAt = updatedAt ?? DateTime.now();
    return entity;
  }

  void touch() {
    updatedAt = DateTime.now();
  }
}
