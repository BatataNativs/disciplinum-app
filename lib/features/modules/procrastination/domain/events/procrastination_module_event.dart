import 'package:disciplinum/core/modules/contracts/module_event_contract.dart';

/// Eventos do módulo Procrastination
class ProcrastinationModuleEvent implements ModuleEventContract {
  @override
  final String eventType;
  @override
  final String moduleId = 'procrastination';
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

  ProcrastinationModuleEvent({
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

/// Factory de eventos do módulo Procrastination
class ProcrastinationEventFactory implements ModuleEventFactory<ProcrastinationModuleEvent> {
  @override
  String get moduleId => 'procrastination';

  @override
  ProcrastinationModuleEvent createSessionStarted({required String userId, Map<String, dynamic>? payload}) => 
    ProcrastinationModuleEvent(eventType: 'session_started', userId: userId, category: ModuleEventCategory.sessionStarted, payload: payload ?? {});

  @override
  ProcrastinationModuleEvent createSessionCompleted({required String userId, required bool wasSuccessful, Map<String, dynamic>? payload}) => 
    ProcrastinationModuleEvent(eventType: 'session_completed', userId: userId, category: ModuleEventCategory.sessionCompleted, payload: {...?payload, 'was_successful': wasSuccessful});

  @override
  ProcrastinationModuleEvent createProgressUpdated({required String userId, required String metricName, required newValue, Map<String, dynamic>? payload}) => 
    ProcrastinationModuleEvent(eventType: 'progress_updated', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {...?payload, 'metric_name': metricName, 'new_value': newValue});

  @override
  ProcrastinationModuleEvent createGoalReached({required String userId, required String goalName, Map<String, dynamic>? payload}) => 
    ProcrastinationModuleEvent(eventType: 'goal_reached', userId: userId, category: ModuleEventCategory.goalReached, payload: {...?payload, 'goal_name': goalName});

  @override
  ProcrastinationModuleEvent createCustom({required String eventType, required String userId, required ModuleEventCategory category, Map<String, dynamic>? payload}) => 
    ProcrastinationModuleEvent(eventType: eventType, userId: userId, category: category, payload: payload ?? {});

  ProcrastinationModuleEvent createTaskStarted(String userId, {required String taskId}) => 
    ProcrastinationModuleEvent(eventType: 'task_started', userId: userId, category: ModuleEventCategory.sessionStarted, payload: {'task_id': taskId});

  ProcrastinationModuleEvent createTaskCompleted(String userId, {required String taskId, required int pomodorosUsed}) => 
    ProcrastinationModuleEvent(eventType: 'task_completed', userId: userId, category: ModuleEventCategory.goalReached, payload: {'task_id': taskId, 'pomodoros_used': pomodorosUsed});

  ProcrastinationModuleEvent createDistractionBlocked(String userId, {required String appBlocked}) => 
    ProcrastinationModuleEvent(eventType: 'distraction_blocked', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {'app_blocked': appBlocked});
}
