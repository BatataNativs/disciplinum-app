import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

/// Eventos relacionados a gamificação
/// Emitidos quando há conquistas, progresso ou mudanças de estado

class MedalAwardedEvent extends AppEvent {
  final NicheId nicheId;
  final Map<String, dynamic> medal;
  final int consecutiveDays;
  final String? userId;

  MedalAwardedEvent({
    required this.nicheId,
    required this.medal,
    required this.consecutiveDays,
    this.userId,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'medal': medal,
      'consecutiveDays': consecutiveDays,
      'userId': userId,
    },
  );

  String get description => 'Medal awarded for niche $nicheId';
}

class ModuleActivatedEvent extends AppEvent {
  final NicheId nicheId;
  final String? userId;
  final DateTime activationDate;
  final Map<String, dynamic>? settings;

  ModuleActivatedEvent({
    required this.nicheId,
    this.userId,
    required this.activationDate,
    this.settings,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'userId': userId,
      'activationDate': activationDate.toIso8601String(),
      'settings': settings,
    },
  );

  String get description => 'Module activated: $nicheId';
}

class ModuleDeactivatedEvent extends AppEvent {
  final NicheId nicheId;
  final String? userId;
  final DateTime deactivationDate;
  final String? reason;

  ModuleDeactivatedEvent({
    required this.nicheId,
    this.userId,
    required this.deactivationDate,
    this.reason,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'userId': userId,
      'deactivationDate': deactivationDate.toIso8601String(),
      'reason': reason,
    },
  );

  String get description => 'Module deactivated: $nicheId';
}

class StreakUpdatedEvent extends AppEvent {
  final NicheId nicheId;
  final String? userId;
  final int newStreak;
  final int previousStreak;
  final bool isRecord;

  StreakUpdatedEvent({
    required this.nicheId,
    this.userId,
    required this.newStreak,
    required this.previousStreak,
    required this.isRecord,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'userId': userId,
      'newStreak': newStreak,
      'previousStreak': previousStreak,
      'isRecord': isRecord,
    },
  );

  String get description => 'Streak updated for $nicheId: $previousStreak -> $newStreak';
}

class FocusInsigniaAwardedEvent extends AppEvent {
  final NicheId nicheId;
  final String? userId;
  final Map<String, dynamic> insignia;
  final int totalFocusTime;

  FocusInsigniaAwardedEvent({
    required this.nicheId,
    this.userId,
    required this.insignia,
    required this.totalFocusTime,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'userId': userId,
      'insignia': insignia,
      'totalFocusTime': totalFocusTime,
    },
  );

  String get description => 'Focus insignia awarded for $nicheId';
}

class FocusPeriodCompletedEvent extends AppEvent {
  final NicheId nicheId;
  final String? userId;
  final Duration focusDuration;
  final int completedSessions;
  final bool wasProductive;

  FocusPeriodCompletedEvent({
    required this.nicheId,
    this.userId,
    required this.focusDuration,
    required this.completedSessions,
    required this.wasProductive,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'userId': userId,
      'focusDuration': focusDuration.inMinutes,
      'completedSessions': completedSessions,
      'wasProductive': wasProductive,
    },
  );

  String get description => 'Focus period completed for $nicheId: ${focusDuration.inMinutes}min';
}

class AchievementUnlockedEvent extends AppEvent {
  final NicheId nicheId;
  final String? userId;
  final String achievementId;
  final String achievementName;
  final String description;
  final int pointsAwarded;

  AchievementUnlockedEvent({
    required this.nicheId,
    this.userId,
    required this.achievementId,
    required this.achievementName,
    required this.description,
    required this.pointsAwarded,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'userId': userId,
      'achievementId': achievementId,
      'achievementName': achievementName,
      'description': description,
      'pointsAwarded': pointsAwarded,
    },
  );

  String get eventDescription => 'Achievement unlocked: $achievementName';
}
