import 'package:disciplinum/core/modules/contracts/module_event_contract.dart';

/// Eventos do módulo Diet
class DietModuleEvent implements ModuleEventContract {
  final String _eventType;
  final String _userId;
  final DateTime _timestamp;
  final Map<String, dynamic> _payload;
  final ModuleEventCategory _category;

  DietModuleEvent({
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
  String get moduleId => 'diet';

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

/// Factory de eventos do módulo Diet
class DietEventFactory implements ModuleEventFactory<DietModuleEvent> {
  @override
  String get moduleId => 'diet';

  @override
  DietModuleEvent createSessionStarted({required String userId, Map<String, dynamic>? payload}) => 
    DietModuleEvent(eventType: 'session_started', userId: userId, category: ModuleEventCategory.sessionStarted, payload: payload ?? {});

  @override
  DietModuleEvent createSessionCompleted({required String userId, required bool wasSuccessful, Map<String, dynamic>? payload}) => 
    DietModuleEvent(eventType: 'session_completed', userId: userId, category: ModuleEventCategory.sessionCompleted, payload: {...?payload, 'was_successful': wasSuccessful});

  @override
  DietModuleEvent createProgressUpdated({required String userId, required String metricName, required newValue, Map<String, dynamic>? payload}) => 
    DietModuleEvent(eventType: 'progress_updated', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {...?payload, 'metric_name': metricName, 'new_value': newValue});

  @override
  DietModuleEvent createGoalReached({required String userId, required String goalName, Map<String, dynamic>? payload}) => 
    DietModuleEvent(eventType: 'goal_reached', userId: userId, category: ModuleEventCategory.goalReached, payload: {...?payload, 'goal_name': goalName});

  @override
  DietModuleEvent createCustom({required String eventType, required String userId, required ModuleEventCategory category, Map<String, dynamic>? payload}) => 
    DietModuleEvent(eventType: eventType, userId: userId, category: category, payload: payload ?? {});

  DietModuleEvent createMealLogged(String userId, {required bool wasHealthy}) => 
    DietModuleEvent(eventType: 'meal_logged', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {'was_healthy': wasHealthy});

  DietModuleEvent createWaterIntakeLogged(String userId, {required int glasses}) => 
    DietModuleEvent(eventType: 'water_intake_logged', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {'glasses': glasses});
}
