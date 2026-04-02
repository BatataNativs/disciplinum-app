import 'package:disciplinum/core/modules/contracts/module_event_contract.dart';

/// Eventos do módulo Diet
class DietModuleEvent implements ModuleEventContract {
  @override
  final String eventType;
  @override
  final String moduleId = 'diet';
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

  DietModuleEvent({
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
