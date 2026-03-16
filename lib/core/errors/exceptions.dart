import 'package:flutter/foundation.dart';

/// Exceção base para erros do aplicativo
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.data,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }

  /// Converte para JSON para logging/analytics
  Map<String, dynamic> toJson() {
    return {
      'type': runtimeType.toString(),
      'message': message,
      'code': code,
      'data': data,
      'stackTrace': stackTrace?.toString(),
    };
  }
}

/// Exceção para erros de validação
class ValidationException extends AppException {
  final String? field;
  final dynamic value;

  const ValidationException({
    required super.message,
    this.field,
    this.value,
    super.code,
    super.data,
    super.stackTrace,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['field'] = field;
    json['value'] = value;
    return json;
  }
}

/// Exceção para erros de rede
class NetworkException extends AppException {
  final int? statusCode;
  final String? url;
  final Map<String, String>? headers;

  const NetworkException({
    required super.message,
    this.statusCode,
    this.url,
    this.headers,
    super.code,
    super.data,
    super.stackTrace,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['statusCode'] = statusCode;
    json['url'] = url;
    json['headers'] = headers;
    return json;
  }
}

/// Exceção para erros de persistência
class PersistenceException extends AppException {
  final String? operation;
  final String? collection;
  final dynamic query;

  const PersistenceException({
    required super.message,
    this.operation,
    this.collection,
    this.query,
    super.code,
    super.data,
    super.stackTrace,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['operation'] = operation;
    json['collection'] = collection;
    json['query'] = query;
    return json;
  }
}

/// Exceção para erros de monitoramento
class MonitoringException extends AppException {
  final String? service;
  final String? event;
  final dynamic eventData;

  const MonitoringException({
    required super.message,
    this.service,
    this.event,
    this.eventData,
    super.code,
    super.data,
    super.stackTrace,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['service'] = service;
    json['event'] = event;
    json['eventData'] = eventData;
    return json;
  }
}

/// Exceção para erros de autenticação
class AuthenticationException extends AppException {
  final String? provider;
  final String? userId;

  const AuthenticationException({
    required super.message,
    this.provider,
    this.userId,
    super.code,
    super.data,
    super.stackTrace,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['provider'] = provider;
    json['userId'] = userId;
    return json;
  }
}

/// Exceção para erros de autorização
class AuthorizationException extends AppException {
  final String? resource;
  final String? action;
  final String? userId;

  const AuthorizationException({
    required super.message,
    this.resource,
    this.action,
    this.userId,
    super.code,
    super.data,
    super.stackTrace,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['resource'] = resource;
    json['action'] = action;
    json['userId'] = userId;
    return json;
  }
}

/// Exceção para erros de configuração
class ConfigurationException extends AppException {
  final String? configKey;
  final dynamic configValue;

  const ConfigurationException({
    required super.message,
    this.configKey,
    this.configValue,
    super.code,
    super.data,
    super.stackTrace,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['configKey'] = configKey;
    json['configValue'] = configValue;
    return json;
  }
}

/// Exceção para erros de estado
class StateException extends AppException {
  final String? currentState;
  final String? expectedState;
  final String? transition;

  const StateException({
    required super.message,
    this.currentState,
    this.expectedState,
    this.transition,
    super.code,
    super.data,
    super.stackTrace,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['currentState'] = currentState;
    json['expectedState'] = expectedState;
    json['transition'] = transition;
    return json;
  }
}

/// Exceção para erros de cache
class CacheException extends AppException {
  final String? key;
  final String? operation;

  const CacheException({
    required super.message,
    this.key,
    this.operation,
/// Factory para criar exceções com contexto automático
class ExceptionFactory {
  /// Cria uma exceção com stack trace automático
  static T create<T extends AppException>(
    String exceptionType,
    T Function() exceptionCreator,
  ) {
    try {
      return exceptionCreator();
    } catch (e, stackTrace) {
      if (e is AppException) {
        // Recria a exceção com o stack trace
        return _recreateWithStackTrace(e, stackTrace) as T;
      }
      rethrow;
    }
  }

  /// Recria uma exceção com stack trace
  static AppException _recreateWithStackTrace(AppException original, StackTrace stackTrace) {
    switch (original.runtimeType) {
      case ValidationException:
        final validation = original as ValidationException;
        return ValidationException(
          message: validation.message,
          field: validation.field,
          value: validation.value,
          code: validation.code,
          data: validation.data,
          stackTrace: stackTrace,
        );
      case NetworkException:
        final network = original as NetworkException;
        return NetworkException(
          message: network.message,
          statusCode: network.statusCode,
          url: network.url,
          headers: network.headers,
          code: network.code,
          data: network.data,
          stackTrace: stackTrace,
        );
      case PersistenceException:
        final persistence = original as PersistenceException;
        return PersistenceException(
          message: persistence.message,
          operation: persistence.operation,
          collection: persistence.collection,
          query: persistence.query,
          code: persistence.code,
          data: persistence.data,
          stackTrace: stackTrace,
        );
      case MonitoringException:
        final monitoring = original as MonitoringException;
        return MonitoringException(
          message: monitoring.message,
          service: monitoring.service,
          event: monitoring.event,
          eventData: monitoring.eventData,
          code: monitoring.code,
          data: monitoring.data,
          stackTrace: stackTrace,
        );
      case AuthenticationException:
        final auth = original as AuthenticationException;
        return AuthenticationException(
          message: auth.message,
          provider: auth.provider,
          userId: auth.userId,
          code: auth.code,
          data: auth.data,
          stackTrace: stackTrace,
        );
      case AuthorizationException:
        final authz = original as AuthorizationException;
        return AuthorizationException(
          message: authz.message,
          resource: authz.resource,
          action: authz.action,
          userId: authz.userId,
          code: authz.code,
          data: authz.data,
          stackTrace: stackTrace,
        );
      case ConfigurationException:
        final config = original as ConfigurationException;
        return ConfigurationException(
          message: config.message,
          configKey: config.configKey,
          configValue: config.configValue,
          code: config.code,
          data: config.data,
          stackTrace: stackTrace,
        );
      case StateException:
        final state = original as StateException;
        return StateException(
          message: state.message,
          currentState: state.currentState,
          expectedState: state.expectedState,
          transition: state.transition,
          code: state.code,
          data: state.data,
          stackTrace: stackTrace,
        );
      case CacheException:
        final cache = original as CacheException;
        return CacheException(
          message: cache.message,
          key: cache.key,
          operation: cache.operation,
          code: cache.code,
          data: cache.data,
          stackTrace: stackTrace,
        );
      default:
        return GenericException(
          message: original.message,
          code: original.code,
          data: original.data,
          stackTrace: stackTrace,
        );
    }
  }
}

/// Exceção genérica para erros não categorizados
class GenericException extends AppException {
  const GenericException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
  });
}

/// Utilitários para tratamento de exceções
class ExceptionUtils {
  /// Verifica se uma exceção é recuperável
  static bool isRecoverable(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        final network = exception as NetworkException;
        // Erros de rede geralmente são recuperáveis
        return network.statusCode == null || 
               network.statusCode! >= 500 || 
               network.statusCode == 408;
      case CacheException:
        // Erros de cache são recuperáveis
        return true;
      case ValidationException:
        // Erros de validação não são recuperáveis automaticamente
        return false;
      case AuthenticationException:
      case AuthorizationException:
        // Erros de auth podem ser recuperáveis com re-login
        return true;
      default:
        return false;
    }
  }

  /// Obtém mensagem amigável para o usuário
  static String getUserFriendlyMessage(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkException:
        return 'Erro de conexão. Verifique sua internet e tente novamente.';
      case ValidationException:
        return 'Dados inválidos. Verifique as informações e tente novamente.';
      case AuthenticationException:
        return 'Erro de autenticação. Faça login novamente.';
      case AuthorizationException:
        return 'Você não tem permissão para realizar esta ação.';
      case PersistenceException:
        return 'Erro ao salvar dados. Tente novamente.';
      case ConfigurationException:
        return 'Erro de configuração. Contate o suporte.';
      case StateException:
        return 'Operação não permitida no momento. Tente novamente.';
      case CacheException:
        return 'Erro de cache. Tente novamente.';
      case MonitoringException:
        return 'Erro no sistema. Tente novamente.';
      default:
        return 'Ocorreu um erro inesperado. Tente novamente.';
    }
  }

  /// Loga exceção com informações detalhadas
  static void logException(AppException exception, [String? context]) {
    if (kDebugMode) {
      debugPrint('=== EXCEPTION ===');
      debugPrint('Context: $context');
      debugPrint('Type: ${exception.runtimeType}');
      debugPrint('Message: ${exception.message}');
      debugPrint('Code: ${exception.code}');
      debugPrint('Data: ${exception.data}');
      debugPrint('Stack Trace: ${exception.stackTrace}');
      debugPrint('JSON: ${exception.toJson()}');
      debugPrint('================');
    }
  }
}
