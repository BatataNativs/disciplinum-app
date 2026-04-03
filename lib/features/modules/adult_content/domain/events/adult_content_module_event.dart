import 'package:disciplinum/core/modules/contracts/module_event_contract.dart';

/// Eventos do módulo Adult Content
class AdultContentModuleEvent implements ModuleEventContract {
  final String _eventType;
  final String _userId;
  final DateTime _timestamp;
  final Map<String, dynamic> _payload;
  final ModuleEventCategory _category;

  AdultContentModuleEvent({
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
  String get moduleId => 'adult_content';

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

/// Factory de eventos do módulo Adult Content
class AdultContentEventFactory implements ModuleEventFactory<AdultContentModuleEvent> {
  @override
  String get moduleId => 'adult_content';

  @override
  AdultContentModuleEvent createSessionStarted({required String userId, Map<String, dynamic>? payload}) => 
    AdultContentModuleEvent(eventType: 'session_started', userId: userId, category: ModuleEventCategory.sessionStarted, payload: payload ?? {});

  @override
  AdultContentModuleEvent createSessionCompleted({required String userId, required bool wasSuccessful, Map<String, dynamic>? payload}) => 
    AdultContentModuleEvent(eventType: 'session_completed', userId: userId, category: ModuleEventCategory.sessionCompleted, payload: {...?payload, 'was_successful': wasSuccessful});

  @override
  AdultContentModuleEvent createProgressUpdated({required String userId, required String metricName, required newValue, Map<String, dynamic>? payload}) => 
    AdultContentModuleEvent(eventType: 'progress_updated', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {...?payload, 'metric_name': metricName, 'new_value': newValue});

  @override
  AdultContentModuleEvent createGoalReached({required String userId, required String goalName, Map<String, dynamic>? payload}) => 
    AdultContentModuleEvent(eventType: 'goal_reached', userId: userId, category: ModuleEventCategory.goalReached, payload: {...?payload, 'goal_name': goalName});

  @override
  AdultContentModuleEvent createCustom({required String eventType, required String userId, required ModuleEventCategory category, Map<String, dynamic>? payload}) => 
    AdultContentModuleEvent(eventType: eventType, userId: userId, category: category, payload: payload ?? {});

  AdultContentModuleEvent createAccessBlocked(String userId, {required String appPackage}) => 
    AdultContentModuleEvent(eventType: 'access_blocked', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {'app_package': appPackage});

  AdultContentModuleEvent createCleanDayCompleted(String userId, {required int streakDays}) => 
    AdultContentModuleEvent(eventType: 'clean_day_completed', userId: userId, category: ModuleEventCategory.progressUpdated, payload: {'streak_days': streakDays});
}
