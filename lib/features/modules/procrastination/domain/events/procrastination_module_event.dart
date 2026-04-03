import 'package:disciplinum/core/modules/contracts/module_event_contract.dart';

/// Eventos do módulo Procrastination
class ProcrastinationModuleEvent implements ModuleEventContract {
  final String _eventType;
  final String _userId;
  final DateTime _timestamp;
  final Map<String, dynamic> _payload;
  final ModuleEventCategory _category;

  ProcrastinationModuleEvent({
    required String eventType,
    required String userId,
    required ModuleEventCategory category,
    Map<String, dynamic>? payload,
    DateTime? timestamp,
  })  : _eventType = eventType,
        _userId = userId,
        _category = category,
        _payload = payload ?? const {},
        _timestamp = timestamp ?? DateTime.now();

  @override
  String get eventType => _eventType;

  @override
  String get moduleId => 'procrastination';

  @override
  String get userId => _userId;

  @override
  DateTime get timestamp => _timestamp;

  @override
  Map<String, dynamic> get payload => _payload;

  @override
  int get eventVersion => 1;

  @override
  ModuleEventCategory get category => _category;

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
