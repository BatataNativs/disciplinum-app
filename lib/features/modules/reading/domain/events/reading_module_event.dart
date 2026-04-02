import 'package:disciplinum/core/modules/contracts/module_event_contract.dart';

/// Eventos do módulo Reading
class ReadingModuleEvent implements ModuleEventContract {
  @override
  final String eventType;
  @override
  final String moduleId = 'reading';
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

  ReadingModuleEvent({
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

/// Factory de eventos do módulo Reading
class ReadingEventFactory implements ModuleEventFactory<ReadingModuleEvent> {
  @override
  String get moduleId => 'reading';

  @override
  ReadingModuleEvent createSessionStarted({required String userId, Map<String, dynamic>? payload}) => 
    ReadingModuleEvent(eventType: 'session_started', userId: userId, category: ModuleEventCategory.sessionStarted, payload: payload ?? {});

  @override
  ReadingModuleEvent createSessionCompleted({required String userId, required bool wasSuccessful, Map<String, dynamic>? payload}) => 
    ReadingModuleEvent(eventType: 'session_completed', userId: userId, category: ModuleEventCategory.sessionCompleted, payload: {...?payload, 'was_successful': wasSuccessful});

  @override
  ReadingModuleEvent createProgressUpdated({required String userId, required String metricName, required newValue, Map<String, dynamic>? payload}) => 
    ReadingModuleEvent(eventType: 'progress_updated', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {...?payload, 'metric_name': metricName, 'new_value': newValue});

  @override
  ReadingModuleEvent createGoalReached({required String userId, required String goalName, Map<String, dynamic>? payload}) => 
    ReadingModuleEvent(eventType: 'goal_reached', userId: userId, category: ModuleEventCategory.goalReached, payload: {...?payload, 'goal_name': goalName});

  @override
  ReadingModuleEvent createCustom({required String eventType, required String userId, required ModuleEventCategory category, Map<String, dynamic>? payload}) => 
    ReadingModuleEvent(eventType: eventType, userId: userId, category: category, payload: payload ?? {});

  ReadingModuleEvent createBookCompleted(String userId, {required String bookTitle, required int pagesRead}) => 
    ReadingModuleEvent(eventType: 'book_completed', userId: userId, category: ModuleEventCategory.goalReached, payload: {'book_title': bookTitle, 'pages_read': pagesRead});

  ReadingModuleEvent createReadingStreakUpdated(String userId, {required int currentStreak}) => 
    ReadingModuleEvent(eventType: 'reading_streak_updated', userId: userId, category: ModuleEventCategory.streakUpdated, payload: {'current_streak': currentStreak});
}
