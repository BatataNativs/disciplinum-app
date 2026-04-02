import 'package:disciplinum/core/modules/contracts/module_event_contract.dart';

/// Eventos do módulo Money Saving
class MoneySavingModuleEvent implements ModuleEventContract {
  @override
  final String eventType;
  @override
  final String moduleId = 'money_saving';
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

  MoneySavingModuleEvent({
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

/// Factory de eventos do módulo Money Saving
class MoneySavingEventFactory implements ModuleEventFactory<MoneySavingModuleEvent> {
  @override
  String get moduleId => 'money_saving';

  @override
  MoneySavingModuleEvent createSessionStarted({required String userId, Map<String, dynamic>? payload}) => 
    MoneySavingModuleEvent(eventType: 'session_started', userId: userId, category: ModuleEventCategory.sessionStarted, payload: payload ?? {});

  @override
  MoneySavingModuleEvent createSessionCompleted({required String userId, required bool wasSuccessful, Map<String, dynamic>? payload}) => 
    MoneySavingModuleEvent(eventType: 'session_completed', userId: userId, category: ModuleEventCategory.sessionCompleted, payload: {...?payload, 'was_successful': wasSuccessful});

  @override
  MoneySavingModuleEvent createProgressUpdated({required String userId, required String metricName, required newValue, Map<String, dynamic>? payload}) => 
    MoneySavingModuleEvent(eventType: 'progress_updated', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {...?payload, 'metric_name': metricName, 'new_value': newValue});

  @override
  MoneySavingModuleEvent createGoalReached({required String userId, required String goalName, Map<String, dynamic>? payload}) => 
    MoneySavingModuleEvent(eventType: 'goal_reached', userId: userId, category: ModuleEventCategory.goalReached, payload: {...?payload, 'goal_name': goalName});

  @override
  MoneySavingModuleEvent createCustom({required String eventType, required String userId, required ModuleEventCategory category, Map<String, dynamic>? payload}) => 
    MoneySavingModuleEvent(eventType: eventType, userId: userId, category: category, payload: payload ?? {});

  MoneySavingModuleEvent createAmountSaved(String userId, {required double amount}) => 
    MoneySavingModuleEvent(eventType: 'amount_saved', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {'amount': amount});

  MoneySavingModuleEvent createGoalCompleted(String userId, {required String goalName, required double totalSaved}) => 
    MoneySavingModuleEvent(eventType: 'saving_goal_completed', userId: userId, category: ModuleEventCategory.goalReached, payload: {'goal_name': goalName, 'total_saved': totalSaved});
}
