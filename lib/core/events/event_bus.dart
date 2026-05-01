import 'dart:async';
import 'package:disciplinum/core/logging/logger_service.dart';

/// EventBus central para comunicação desacoplada
/// Permite que módulos se comuniquem sem dependências diretas
class EventBus {
  static final EventBus _instance = EventBus._internal();
  static EventBus get instance => _instance;
  
  EventBus._internal();
  
  final StreamController<AppEvent> _controller = StreamController<AppEvent>.broadcast();
  final Map<Type, List<Function(AppEvent)>> _listeners = {};
  
  /// Stream para ouvir todos os eventos
  Stream<AppEvent> get stream => _controller.stream;
  
  /// Emite um evento para todos os listeners
  void emit(AppEvent event) {
    LoggerService.instance.analytics('Event emitted', {
      'event_type': event.runtimeType.toString(),
      'event_data': event.data,
    });
    
    _controller.add(event);
    
    // Notificar listeners específicos
    final eventType = event.runtimeType;
    if (_listeners.containsKey(eventType)) {
      for (final listener in _listeners[eventType]!) {
        try {
          listener(event);
        } catch (e) {
          LoggerService.instance.e('Error in event listener', 
             error: e, stackTrace: StackTrace.current);
        }
      }
    }
  }
  
  /// Registra listener para tipo específico de evento
  void listen<T extends AppEvent>(Function(T event) listener) {
    final eventType = T;
    _listeners.putIfAbsent(eventType, () => <Function(AppEvent)>[]);
    _listeners[eventType]!.add((event) => listener(event as T));
    
    LoggerService.instance.d('Event listener registered', error: {
      'event_type': eventType.toString(),
    });
  }
  
  /// Remove listener específico
  void removeListener<T extends AppEvent>(Function(T event) listener) {
    final eventType = T;
    if (_listeners.containsKey(eventType)) {
      _listeners[eventType]!.removeWhere((l) => l == listener);
      if (_listeners[eventType]!.isEmpty) {
        _listeners.remove(eventType);
      }
    }
  }
  
  /// Remove todos os listeners
  void clearListeners() {
    _listeners.clear();
    LoggerService.instance.i('All event listeners cleared');
  }
  
  /// Obtém número de listeners ativos
  int get listenerCount => _listeners.values.fold(0, (sum, listeners) => sum + listeners.length);
  
  /// Verifica se tem listeners para tipo específico
  bool hasListeners<T extends AppEvent>() {
    return _listeners.containsKey(T) && _listeners[T]!.isNotEmpty;
  }
  
  /// Fecha o EventBus (chamar no dispose do app)
  void dispose() {
    _controller.close();
    clearListeners();
    LoggerService.instance.i('EventBus disposed');
  }
}

/// Classe base para todos os eventos do aplicativo
abstract class AppEvent {
  final DateTime timestamp;
  final Map<String, dynamic> data;
  final String? sessionId;
  
  AppEvent({
    Map<String, dynamic>? data,
    this.sessionId,
  }) : timestamp = DateTime.now(),
       data = data ?? {};
  
  Map<String, dynamic> toJson() {
    return {
      'event_type': runtimeType.toString(),
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'session_id': sessionId,
    };
  }
  
  @override
  String toString() {
    return '${runtimeType.toString()}(timestamp: $timestamp, data: $data)';
  }
}

/// Eventos de Gamificação
class MedalEarnedEvent extends AppEvent {
  final int nicheId;
  final String medalType;
  final String medalName;
  
  MedalEarnedEvent({
    required this.nicheId,
    required this.medalType,
    required this.medalName,
    super.sessionId,
  }) : super(
    data: {
      'niche_id': nicheId,
      'medal_type': medalType,
      'medal_name': medalName,
    },
  );
}


class ModuleStartedEvent extends AppEvent {
  final int nicheId;
  final String? source;
  
  ModuleStartedEvent({
    required this.nicheId,
    this.source,
    super.sessionId,
  }) : super(
    data: {
      'niche_id': nicheId,
      if (source != null) 'source': source,
    },
  );
}

class ModuleStoppedEvent extends AppEvent {
  final int nicheId;
  final String reason;
  
  ModuleStoppedEvent({
    required this.nicheId,
    required this.reason,
    super.sessionId,
  }) : super(
    data: {
      'niche_id': nicheId,
      'reason': reason,
    },
  );
}

/// Eventos de Hábitos
class SpendingGoalReachedEvent extends AppEvent {
  final int nicheId;
  final double goalAmount;
  final double currentAmount;
  
  SpendingGoalReachedEvent({
    required this.nicheId,
    required this.goalAmount,
    required this.currentAmount,
    super.sessionId,
  }) : super(
    data: {
      'niche_id': nicheId,
      'goal_amount': goalAmount,
      'current_amount': currentAmount,
    },
  );
}

class SmokingRelapseEvent extends AppEvent {
  final int nicheId;
  final String reason;
  final int previousStreak;
  
  SmokingRelapseEvent({
    required this.nicheId,
    required this.reason,
    required this.previousStreak,
    super.sessionId,
  }) : super(
    data: {
      'niche_id': nicheId,
      'reason': reason,
      'previous_streak': previousStreak,
    },
  );
}

class ReadingSessionCompletedEvent extends AppEvent {
  final int nicheId;
  final int pagesRead;
  final int durationMinutes;
  
  ReadingSessionCompletedEvent({
    required this.nicheId,
    required this.pagesRead,
    required this.durationMinutes,
    super.sessionId,
  }) : super(
    data: {
      'niche_id': nicheId,
      'pages_read': pagesRead,
      'duration_minutes': durationMinutes,
    },
  );
}

class ProcrastinationTaskCompletedEvent extends AppEvent {
  final int nicheId;
  final String taskId;
  final String taskTitle;
  final int durationMinutes;
  
  ProcrastinationTaskCompletedEvent({
    required this.nicheId,
    required this.taskId,
    required this.taskTitle,
    required this.durationMinutes,
    super.sessionId,
  }) : super(
    data: {
      'niche_id': nicheId,
      'task_id': taskId,
      'task_title': taskTitle,
      'duration_minutes': durationMinutes,
    },
  );
}

/// Eventos do Sistema
class AppBackgroundedEvent extends AppEvent {
  AppBackgroundedEvent({super.sessionId});
}

class AppForegroundedEvent extends AppEvent {
  AppForegroundedEvent({super.sessionId});
}

class NetworkStatusChangedEvent extends AppEvent {
  final bool isConnected;

  NetworkStatusChangedEvent({
    required this.isConnected,
    super.sessionId,
  }) : super(
    data: {'is_connected': isConnected},
  );
}

/// Eventos de Usuário
class UserLoggedInEvent extends AppEvent {
  final String userId;
  final String? email;

  UserLoggedInEvent({
    required this.userId,
    this.email,
    super.sessionId,
  }) : super(
    data: {
      'user_id': userId,
      if (email != null) 'email': email,
    },
  );
}

class UserLoggedOutEvent extends AppEvent {
  final String userId;

  UserLoggedOutEvent({
    required this.userId,
    super.sessionId,
  }) : super(
    data: {'user_id': userId},
  );
}

/// Evento de Check-in para módulos
class ModuleCheckInEvent extends AppEvent {
  final int nicheId;
  final bool isPositive; // true = check-in positivo (não fumou, etc)
  final DateTime checkInDate;
  
  ModuleCheckInEvent({
    required this.nicheId,
    required this.isPositive,
    required this.checkInDate,
    super.sessionId,
  }) : super(
    data: {
      'niche_id': nicheId,
      'is_positive': isPositive,
      'check_in_date': checkInDate.toIso8601String(),
    },
  );
}

/// Helper method para facilitar emissão de eventos
class EventEmitHelper {
  static void emitModuleCheckIn({
    required int nicheId,
    required bool isPositive,
    required DateTime checkInDate,
  }) {
    EventBus.instance.emit(ModuleCheckInEvent(
      nicheId: nicheId,
      isPositive: isPositive,
      checkInDate: checkInDate,
    ));
  }
  
  static void emitMedalEarned({
    required int nicheId,
    required String medalType,
    required String medalName,
  }) {
    EventBus.instance.emit(MedalEarnedEvent(
      nicheId: nicheId,
      medalType: medalType,
      medalName: medalName,
    ));
  }
  
  static void emitModuleStarted({
    required int nicheId,
    String? source,
  }) {
    EventBus.instance.emit(ModuleStartedEvent(
      nicheId: nicheId,
      source: source,
    ));
  }
  
  static void emitSmokingRelapse({
    required int nicheId,
    required String reason,
    required int previousStreak,
  }) {
    EventBus.instance.emit(SmokingRelapseEvent(
      nicheId: nicheId,
      reason: reason,
      previousStreak: previousStreak,
    ));
  }
}
