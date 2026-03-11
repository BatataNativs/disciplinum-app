import 'dart:async';
import 'package:flutter/foundation.dart';

/// EventBus centralizado para desacoplamento de componentes
/// Permite comunicação indireta entre serviços sem acoplamento direto
class EventBus {
  static final EventBus _instance = EventBus._internal();
  static EventBus get instance => _instance;
  factory EventBus() => _instance;

  EventBus._internal();

  // Map de listeners por tipo de evento
  final Map<Type, List<Function>> _listeners = {};
  
  // Stream controllers para diferentes tipos de evento
  final Map<Type, StreamController> _controllers = {};

  /// Registra um listener para um tipo específico de evento
  void on<T extends DomainEvent>(void Function(T event) listener) {
    final eventType = T;
    _listeners.putIfAbsent(eventType, () => []).add(listener);
    
    // Criar stream controller se não existir
    _controllers.putIfAbsent(eventType, () => StreamController<T>.broadcast());
  }

  /// Remove um listener específico
  void off<T extends DomainEvent>(void Function(T event) listener) {
    final eventType = T;
    _listeners[eventType]?.remove(listener);
  }

  /// Publica um evento para todos os listeners interessados
  void emit(DomainEvent event) {
    final eventType = event.runtimeType;
    
    // Log em debug para rastreamento
    if (kDebugMode) {
      debugPrint('EventBus: Emitting ${eventType.toString()} - ${event.toString()}');
    }

    // Notificar listeners diretos
    final listeners = _listeners[eventType];
    if (listeners != null) {
      for (final listener in listeners) {
        try {
          listener(event);
        } catch (e) {
          debugPrint('EventBus: Error in listener for $eventType: $e');
        }
      }
    }

    // Notificar via stream (para reatividade)
    final controller = _controllers[eventType];
    if (controller != null && !controller.isClosed) {
      controller.add(event);
    }
  }

  /// Retorna um stream para um tipo específico de evento
  Stream<T> onStream<T extends DomainEvent>() {
    final eventType = T;
    final controller = _controllers.putIfAbsent(
      eventType, 
      () => StreamController<T>.broadcast()
    );
    return controller.stream.cast<T>();
  }

  /// Limpa todos os listeners e controllers (útil para testes)
  void clear() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    _listeners.clear();
    _controllers.clear();
  }

  /// Remove todos os listeners de um tipo específico
  void clearListeners<T extends DomainEvent>() {
    final eventType = T;
    _listeners.remove(eventType);
    
    final controller = _controllers[eventType];
    if (controller != null) {
      controller.close();
      _controllers.remove(eventType);
    }
  }
}

/// Classe base para todos os eventos de domínio
abstract class DomainEvent {
  final DateTime timestamp;
  final String? sessionId;
  
  const DomainEvent({
    required this.timestamp,
    this.sessionId,
  });

  /// Converte o evento para JSON para persistência/analytics
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return '${runtimeType.toString()}(${toJson()})';
  }
}

/// Mixin para facilitar criação de eventos
mixin DomainEventMixin on DomainEvent {
  @override
  Map<String, dynamic> toJson() {
    return {
      'event_type': runtimeType.toString(),
      'timestamp': timestamp.toIso8601String(),
      'session_id': sessionId,
      ...?eventData,
    };
  }

  /// Dados específicos do evento a serem sobrescritos
  Map<String, dynamic>? get eventData;
}
