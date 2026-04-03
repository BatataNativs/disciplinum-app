import 'package:disciplinum/core/modules/contracts/module_event_contract.dart';

/// Eventos do módulo Spending
class SpendingModuleEvent implements ModuleEventContract {
  final String _eventType;
  final String _userId;
  final DateTime _timestamp;
  final Map<String, dynamic> _payload;
  final ModuleEventCategory _category;

  SpendingModuleEvent({
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
  String get moduleId => 'spending';

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

/// Factory de eventos do módulo Spending
class SpendingEventFactory implements ModuleEventFactory<SpendingModuleEvent> {
  @override
  String get moduleId => 'spending';

  @override
  SpendingModuleEvent createSessionStarted({required String userId, Map<String, dynamic>? payload}) => 
    SpendingModuleEvent(eventType: 'session_started', userId: userId, category: ModuleEventCategory.sessionStarted, payload: payload ?? {});

  @override
  SpendingModuleEvent createSessionCompleted({required String userId, required bool wasSuccessful, Map<String, dynamic>? payload}) => 
    SpendingModuleEvent(eventType: 'session_completed', userId: userId, category: ModuleEventCategory.sessionCompleted, payload: {...?payload, 'was_successful': wasSuccessful});

  @override
  SpendingModuleEvent createProgressUpdated({required String userId, required String metricName, required newValue, Map<String, dynamic>? payload}) => 
    SpendingModuleEvent(eventType: 'progress_updated', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {...?payload, 'metric_name': metricName, 'new_value': newValue});

  @override
  SpendingModuleEvent createGoalReached({required String userId, required String goalName, Map<String, dynamic>? payload}) => 
    SpendingModuleEvent(eventType: 'goal_reached', userId: userId, category: ModuleEventCategory.goalReached, payload: {...?payload, 'goal_name': goalName});

  @override
  SpendingModuleEvent createCustom({required String eventType, required String userId, required ModuleEventCategory category, Map<String, dynamic>? payload}) => 
    SpendingModuleEvent(eventType: eventType, userId: userId, category: category, payload: payload ?? {});

  SpendingModuleEvent createPurchaseBlocked(String userId, {required String category, required double amount}) => 
    SpendingModuleEvent(eventType: 'purchase_blocked', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {'category': category, 'amount': amount});

  SpendingModuleEvent createBudgetGoalReached(String userId, {required String period, required double amountSaved}) => 
    SpendingModuleEvent(eventType: 'budget_goal_reached', userId: userId, category: ModuleEventCategory.goalReached, payload: {'period': period, 'amount_saved': amountSaved});

  SpendingModuleEvent createNoSpendDayCompleted(String userId, {required int consecutiveDays}) => 
    SpendingModuleEvent(eventType: 'no_spend_day_completed', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {'consecutive_days': consecutiveDays});
}
