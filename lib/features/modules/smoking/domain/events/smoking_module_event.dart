import 'package:disciplinum/core/modules/contracts/module_event_contract.dart';

/// Eventos do módulo Smoking
class SmokingModuleEvent implements ModuleEventContract {
  @override
  final String eventType;
  @override
  final String moduleId = 'smoking';
  @override
  final String userId;
  @override
  final DateTime timestamp;
  @override
  final Map<String, dynamic> payload;
  @override
  final int eventVersion = 1;
  @override
  final ModuleEventCategory category;

  SmokingModuleEvent({
    required this.eventType,
    required this.userId,
    required this.category,
    this.payload = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  Map<String, dynamic> toJson() => {
    'event_type': eventType,
    'module_id': moduleId,
    'user_id': userId,
    'timestamp': timestamp.toIso8601String(),
    'payload': payload,
    'event_version': eventVersion,
    'category': category.name,
  };
}

/// Factory de eventos do módulo Smoking
class SmokingEventFactory implements ModuleEventFactory<SmokingModuleEvent> {
  @override
  String get moduleId => 'smoking';

  @override
  SmokingModuleEvent createSessionStarted({
    required String userId,
    Map<String, dynamic>? payload,
  }) => SmokingModuleEvent(
    eventType: 'session_started',
    userId: userId,
    category: ModuleEventCategory.sessionStarted,
    payload: payload ?? {},
  );

  @override
  SmokingModuleEvent createSessionCompleted({
    required String userId,
    required bool wasSuccessful,
    Map<String, dynamic>? payload,
  }) => SmokingModuleEvent(
    eventType: 'session_completed',
    userId: userId,
    category: ModuleEventCategory.sessionCompleted,
    payload: {...?payload, 'was_successful': wasSuccessful},
  );

  @override
  SmokingModuleEvent createProgressUpdated({
    required String userId,
    required String metricName,
    required newValue,
    Map<String, dynamic>? payload,
  }) => SmokingModuleEvent(
    eventType: 'progress_updated',
    userId: userId,
    category: ModuleEventCategory.progressUpdated,
    payload: {...?payload, 'metric_name': metricName, 'new_value': newValue},
  );

  @override
  SmokingModuleEvent createGoalReached({
    required String userId,
    required String goalName,
    Map<String, dynamic>? payload,
  }) => SmokingModuleEvent(
    eventType: 'goal_reached',
    userId: userId,
    category: ModuleEventCategory.goalReached,
    payload: {...?payload, 'goal_name': goalName},
  );

  @override
  SmokingModuleEvent createCustom({
    required String eventType,
    required String userId,
    required ModuleEventCategory category,
    Map<String, dynamic>? payload,
  }) => SmokingModuleEvent(
    eventType: eventType,
    userId: userId,
    category: category,
    payload: payload ?? {},
  );

  // Eventos específicos do Smoking
  SmokingModuleEvent createCheckInPositive(String userId) => SmokingModuleEvent(
    eventType: 'check_in_positive',
    userId: userId,
    category: ModuleEventCategory.progressUpdated,
    payload: {'check_in_type': 'positive'},
  );

  SmokingModuleEvent createCheckInNegative(String userId) => SmokingModuleEvent(
    eventType: 'check_in_negative',
    userId: userId,
    category: ModuleEventCategory.relapseDetected,
    payload: {'check_in_type': 'negative'},
  );

  SmokingModuleEvent createStreakReset(String userId, {required int previousStreak}) => SmokingModuleEvent(
    eventType: 'streak_reset',
    userId: userId,
    category: ModuleEventCategory.streakUpdated,
    payload: {'previous_streak': previousStreak},
  );
}
