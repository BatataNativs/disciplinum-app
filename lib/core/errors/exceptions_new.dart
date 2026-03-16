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

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'code': code,
      'data': data,
      'stackTrace': stackTrace?.toString(),
      'type': runtimeType.toString(),
    };
  }
}

/// Exceção para erros de validação
class ValidationException extends AppException {
  final String? field;
  final dynamic value;

  const ValidationException({
    required super.message,
    super.code,
    super.data,
    super.stackTrace,
    this.field,
    this.value,
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
    super.code,
    super.data,
    super.stackTrace,
    this.statusCode,
    this.url,
    this.headers,
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
    super.code,
    super.data,
    super.stackTrace,
    this.operation,
    this.collection,
    this.query,
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
    super.code,
    super.data,
    super.stackTrace,
    this.service,
    this.event,
    this.eventData,
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
    super.code,
    super.data,
    super.stackTrace,
    this.provider,
    this.userId,
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
    super.code,
    super.data,
    super.stackTrace,
    this.resource,
    this.action,
    this.userId,
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
    super.code,
    super.data,
    super.stackTrace,
    this.configKey,
    this.configValue,
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
    super.code,
    super.data,
    super.stackTrace,
    this.currentState,
    this.expectedState,
    this.transition,
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
    super.code,
    super.data,
    super.stackTrace,
    this.key,
    this.operation,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['key'] = key;
    json['operation'] = operation;
    return json;
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
    return switch (exception) {
      NetworkException(:final statusCode) =>
        statusCode == null || statusCode >= 500,
      
      CacheException _ => true,
      
      PersistenceException(:final operation) => operation == 'read',
      
      ValidationException _ ||
      AuthenticationException _ ||
      AuthorizationException _ ||
      ConfigurationException _ ||
      MonitoringException _ ||
      StateException _ => false,
      
      _ => false,
    };
  }

  /// Converte exceção para mensagem amigável
  static String getUserFriendlyMessage(AppException exception) {
    return switch (exception) {
      ValidationException validation =>
        'Campo inválido: ${validation.field ?? 'desconhecido'}',
      
      NetworkException network => network.statusCode != null
        ? 'Erro de conexão (${network.statusCode})'
        : 'Erro de conexão',
      
      AuthenticationException _ => 'Erro de autenticação. Verifique suas credenciais.',
      
      AuthorizationException _ => 'Você não tem permissão para realizar esta ação.',
      
      CacheException _ => 'Erro ao acessar dados locais. Tente novamente.',
      
      PersistenceException _ => 'Erro ao salvar dados. Verifique sua conexão.',
      
      ConfigurationException _ => 'Erro de configuração. Contate o suporte.',
      
      MonitoringException _ => 'Erro de monitoramento. Tente novamente.',
      
      StateException _ => 'Operação não permitida no estado atual.',
      
      _ => exception.message,
    };
  }

  /// Log da exceção
  static void logException(AppException exception, [String? context]) {
    if (kDebugMode) {
      debugPrint('ERROR: ${exception.toString()} ${context != null ? '($context)' : ''}');
    }
  }
}
