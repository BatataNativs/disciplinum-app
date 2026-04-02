import 'package:disciplinum/core/modules/contracts/module_event_contract.dart';

/// Eventos do módulo Binge Eating
class BingeEatingModuleEvent implements ModuleEventContract {
  @override
  final String eventType;
  @override
  final String moduleId = 'binge_eating';
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

  BingeEatingModuleEvent({
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

/// Factory de eventos do módulo Binge Eating
class BingeEatingEventFactory implements ModuleEventFactory<BingeEatingModuleEvent> {
  @override
  String get moduleId => 'binge_eating';

  @override
  BingeEatingModuleEvent createSessionStarted({required String userId, Map<String, dynamic>? payload}) => 
    BingeEatingModuleEvent(eventType: 'session_started', userId: userId, category: ModuleEventCategory.sessionStarted, payload: payload ?? {});

  @override
  BingeEatingModuleEvent createSessionCompleted({required String userId, required bool wasSuccessful, Map<String, dynamic>? payload}) => 
    BingeEatingModuleEvent(eventType: 'session_completed', userId: userId, category: ModuleEventCategory.sessionCompleted, payload: {...?payload, 'was_successful': wasSuccessful});

  @override
  BingeEatingModuleEvent createProgressUpdated({required String userId, required String metricName, required newValue, Map<String, dynamic>? payload}) => 
    BingeEatingModuleEvent(eventType: 'progress_updated', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {...?payload, 'metric_name': metricName, 'new_value': newValue});

  @override
  BingeEatingModuleEvent createGoalReached({required String userId, required String goalName, Map<String, dynamic>? payload}) => 
    BingeEatingModuleEvent(eventType: 'goal_reached', userId: userId, category: ModuleEventCategory.goalReached, payload: {...?payload, 'goal_name': goalName});

  @override
  BingeEatingModuleEvent createCustom({required String eventType, required String userId, required ModuleEventCategory category, Map<String, dynamic>? payload}) => 
    BingeEatingModuleEvent(eventType: eventType, userId: userId, category: category, payload: payload ?? {});

  BingeEatingModuleEvent createCheckInPositive(String userId) => 
    BingeEatingModuleEvent(eventType: 'check_in_positive', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {'check_in_type': 'positive'});

  BingeEatingModuleEvent createCheckInNegative(String userId) => 
    BingeEatingModuleEvent(eventType: 'check_in_negative', userId: userId, category: ModuleEventCategory.relapseDetected, payload: {'check_in_type': 'negative'});

  BingeEatingModuleEvent createStreakReset(String userId, {required int previousStreak}) => 
    BingeEatingModuleEvent(eventType: 'streak_reset', userId: userId, category: ModuleEventCategory.streakUpdated, payload: {'previous_streak': previousStreak});
}
