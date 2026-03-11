import 'package:disciplinum/core/events/event_bus.dart';
import 'package:disciplinum/shared/models/enums/niche_id.dart';

/// Eventos relacionados ao comportamento do usuário
/// Emitidos durante interações, check-ins, recaídas, etc.

class CheckInEvent extends AppEvent {
  final NicheId nicheId;
  final String? userId;
  final CheckInType type;
  final Map<String, dynamic>? additionalData;

  CheckInEvent({
    required this.nicheId,
    this.userId,
    required this.type,
    this.additionalData,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'userId': userId,
      'type': type,
      'additionalData': additionalData,
    },
  );

  String get description => 'Check-in for niche $nicheId with type $type';
}

class RelapseEvent extends AppEvent {
  final NicheId nicheId;
  final String? userId;
  final RelapseType type;
  final String? reason;
  final int streakLost;
  final Map<String, dynamic>? context;

  RelapseEvent({
    required this.nicheId,
    this.userId,
    required this.type,
    this.reason,
    required this.streakLost,
    this.context,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'userId': userId,
      'type': type,
      'reason': reason,
      'streakLost': streakLost,
      'context': context,
    },
  );

  String get description => 'Relapse in niche $nicheId with type $type, lost streak of $streakLost days';
}

class FocusSessionStartedEvent extends AppEvent {
  final NicheId nicheId;
  final String? userId;
  final List<String> blockedApps;
  final Duration plannedDuration;
  final Map<String, dynamic>? settings;

  FocusSessionStartedEvent({
    required this.nicheId,
    this.userId,
    required this.blockedApps,
    required this.plannedDuration,
    this.settings,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'userId': userId,
      'blockedApps': blockedApps,
      'plannedDuration': plannedDuration.inMinutes,
      'settings': settings,
    },
  );

  String get description => 'Focus session started for niche $nicheId with ${blockedApps.length} blocked apps';
}

class FocusSessionCompletedEvent extends AppEvent {
  final NicheId nicheId;
  final String? userId;
  final Duration actualDuration;
  final int interruptionsCount;
  final bool wasSuccessful;
  final List<String> triggeredBlocks;

  FocusSessionCompletedEvent({
    required this.nicheId,
    this.userId,
    required this.actualDuration,
    required this.interruptionsCount,
    required this.wasSuccessful,
    required this.triggeredBlocks,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'userId': userId,
      'actualDuration': actualDuration.inMinutes,
      'interruptionsCount': interruptionsCount,
      'wasSuccessful': wasSuccessful,
      'triggeredBlocks': triggeredBlocks,
    },
  );

  String get description => 'Focus session completed for niche $nicheId: ${wasSuccessful ? "successful" : "failed"}';
}

class AppBlockedEvent extends AppEvent {
  final String packageName;
  final String appName;
  final String? userId;
  final String blockingReason;
  final NicheId? relatedNiche;

  AppBlockedEvent({
    required this.packageName,
    required this.appName,
    this.userId,
    required this.blockingReason,
    this.relatedNiche,
    super.sessionId,
  }) : super(
    data: {
      'packageName': packageName,
      'appName': appName,
      'userId': userId,
      'blockingReason': blockingReason,
      'relatedNiche': relatedNiche,
    },
  );

  String get description => 'App $appName blocked: $blockingReason';
}

class ModuleInteractionEvent extends AppEvent {
  final NicheId nicheId;
  final String? userId;
  final String interactionType;
  final Map<String, dynamic>? interactionData;
  final DateTime? interactionTime;

  ModuleInteractionEvent({
    required this.nicheId,
    this.userId,
    required this.interactionType,
    this.interactionData,
    this.interactionTime,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'userId': userId,
      'interactionType': interactionType,
      'interactionData': interactionData,
      'interactionTime': interactionTime?.toIso8601String(),
    },
  );

  String get description => 'Module interaction: $interactionType for niche $nicheId';
}

class CustomizationEvent extends AppEvent {
  final NicheId nicheId;
  final String? userId;
  final String customizationType;
  final Map<String, dynamic>? customizationData;

  CustomizationEvent({
    required this.nicheId,
    this.userId,
    required this.customizationType,
    this.customizationData,
    super.sessionId,
  }) : super(
    data: {
      'nicheId': nicheId,
      'userId': userId,
      'customizationType': customizationType,
      'customizationData': customizationData,
    },
  );

  String get description => 'Customization event: $customizationType for niche $nicheId';
}

// Enums para tipos de evento
enum CheckInType { daily, weekly, milestone, custom }
enum RelapseType { minor, major, pattern, trigger }
enum FocusSessionResult { completed, abandoned, interrupted }
