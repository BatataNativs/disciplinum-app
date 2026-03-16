/// Exceção base para erros do aplicativo
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  const AppException({
    required this.message,
    this.code,
    this.data,
  });

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

/// Exceção para erros de validação
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.data,
  });
}

/// Exceção para erros de rede
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.data,
  });
}

/// Exceção para erros de persistência
class PersistenceException extends AppException {
  const PersistenceException({
    required super.message,
    super.code,
    super.data,
  });
}

/// Exceção para erros de monitoramento
class MonitoringException extends AppException {
  const MonitoringException({
    required super.message,
    super.code,
    super.data,
  });
}
