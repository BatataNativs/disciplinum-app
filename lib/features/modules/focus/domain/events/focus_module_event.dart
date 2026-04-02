import 'package:disciplinum/core/modules/contracts/module_event_contract.dart';

/// Eventos do módulo Focus
class FocusModuleEvent implements ModuleEventContract {
  @override
  final String eventType;
  @override
  final String moduleId = 'focus';
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

  FocusModuleEvent({
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

/// Factory de eventos do módulo Focus
class FocusEventFactory implements ModuleEventFactory<FocusModuleEvent> {
  @override
  String get moduleId => 'focus';

  @override
  FocusModuleEvent createSessionStarted({
    required String userId,
    Map<String, dynamic>? payload,
  }) => FocusModuleEvent(
    eventType: 'session_started',
    userId: userId,
    category: ModuleEventCategory.sessionStarted,
    payload: payload ?? {},
  );

  @override
  FocusModuleEvent createSessionCompleted({
    required String userId,
    required bool wasSuccessful,
    Map<String, dynamic>? payload,
  }) => FocusModuleEvent(
    eventType: 'session_completed',
    userId: userId,
    category: ModuleEventCategory.sessionCompleted,
    payload: {...?payload, 'was_successful': wasSuccessful},
  );

  @override
  FocusModuleEvent createProgressUpdated({
    required String userId,
    required String metricName,
    required newValue,
    Map<String, dynamic>? payload,
  }) => FocusModuleEvent(
    eventType: 'progress_updated',
    userId: userId,
    category: ModuleEventCategory.progressUpdated,
    payload: {...?payload, 'metric_name': metricName, 'new_value': newValue},
  );

  @override
  FocusModuleEvent createGoalReached({
    required String userId,
    required String goalName,
    Map<String, dynamic>? payload,
  }) => FocusModuleEvent(
    eventType: 'goal_reached',
    userId: userId,
    category: ModuleEventCategory.goalReached,
    payload: {...?payload, 'goal_name': goalName},
  );

  @override
  FocusModuleEvent createCustom({
    required String eventType,
    required String userId,
    required ModuleEventCategory category,
    Map<String, dynamic>? payload,
  }) => FocusModuleEvent(
    eventType: eventType,
    userId: userId,
    category: category,
    payload: payload ?? {},
  );

  // Eventos específicos do Focus
  FocusModuleEvent createTimerStarted(String userId, {required int durationMinutes}) => FocusModuleEvent(
    eventType: 'timer_started',
    userId: userId,
    category: ModuleEventCategory.sessionStarted,
    payload: {'duration_minutes': durationMinutes},
  );

  FocusModuleEvent createTimerCompleted(String userId, {required int actualMinutes}) => FocusModuleEvent(
    eventType: 'timer_completed',
    userId: userId,
    category: ModuleEventCategory.sessionCompleted,
    payload: {'actual_minutes': actualMinutes},
  );

  FocusModuleEvent createAppBlocked(String userId, {required String packageName}) => FocusModuleEvent(
    eventType: 'app_blocked',
    userId: userId,
    category: ModuleEventCategory.progressUpdated,
    payload: {'package_name': packageName},
  );
}
