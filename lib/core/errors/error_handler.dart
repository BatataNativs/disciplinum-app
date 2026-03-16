import 'package:flutter/foundation.dart';
import 'exceptions.dart';

/// Handler central para tratamento de exceções
class ErrorHandler {
  static ErrorHandler? _instance;
  static ErrorHandler get instance => _instance ??= ErrorHandler._();

  ErrorHandler._();

  /// Callback para tratamento de erros
  void Function(AppException exception, String? context)? _onError;

  /// Registra callback para tratamento de erros
  void registerCallbacks({
    void Function(AppException exception, String? context)? onError,
  }) {
    _onError = onError;
  }

  /// Trata uma exceção
  void handleException(
    AppException exception, {
    String? context,
    bool logError = true,
    bool showToUser = false,
  }) {
    // Log da exceção
    if (logError) {
      ExceptionUtils.logException(exception, context);
    }

    // Callback de erro
    _onError?.call(exception, context);

    // Mostrar para o usuário se necessário
    if (showToUser && kDebugMode) {
      debugPrint('USER MESSAGE: ${ExceptionUtils.getUserFriendlyMessage(exception)}');
    }
  }

  /// Trata erro de forma segura
  T safeExecute<T>(
    T Function() operation, {
    String? context,
    T? defaultValue,
    AppException? Function(Object error, StackTrace stackTrace)? exceptionCreator,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      AppException exception;

      if (error is AppException) {
        exception = error;
      } else if (exceptionCreator != null) {
        exception = exceptionCreator(error, stackTrace)!;
      } else {
        exception = GenericException(
          message: error.toString(),
          stackTrace: stackTrace,
        );
      }

      handleException(exception, context: context);
      return defaultValue ?? defaultValue as T;
    }
  }

  /// Trata erro assíncrono de forma segura
  Future<T> safeExecuteAsync<T>(
    Future<T> Function() operation, {
    String? context,
    T? defaultValue,
    AppException? Function(Object error, StackTrace stackTrace)? exceptionCreator,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      AppException exception;

      if (error is AppException) {
        exception = error;
      } else if (exceptionCreator != null) {
        exception = exceptionCreator(error, stackTrace)!;
      } else {
        exception = GenericException(
          message: error.toString(),
          stackTrace: stackTrace,
        );
      }

      handleException(exception, context: context);
      return defaultValue ?? defaultValue as T;
    }
  }

  /// Executa operação com retry
  T executeWithRetry<T>(
    T Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? context,
    bool Function(AppException exception)? shouldRetry,
  }) {
    int attempts = 0;
    AppException? lastException;

    while (attempts < maxRetries) {
      try {
        return operation();
      } catch (error, stackTrace) {
        attempts++;
        
        AppException exception;
        if (error is AppException) {
          exception = error;
        } else {
          exception = GenericException(
            message: error.toString(),
            stackTrace: stackTrace,
          );
        }

        lastException = exception;

        // Verifica se deve tentar novamente
        final shouldRetryNow = shouldRetry?.call(exception) ?? 
                               ExceptionUtils.isRecoverable(exception);

        if (!shouldRetryNow || attempts >= maxRetries) {
          handleException(exception, context: '$context (after $attempts attempts)');
          throw exception;
        }

        // Espera antes da próxima tentativa
        if (attempts < maxRetries) {
          Future.delayed(delay * attempts);
        }
      }
    }

    // Se chegou aqui, todas as tentativas falharam
    final finalException = lastException!;
    handleException(
      finalException, 
      context: '$context (after $maxRetries attempts - all failed)'
    );
    throw finalException;
  }

  /// Executa operação assíncrona com retry
  Future<T> executeWithRetryAsync<T>(
    Future<T> Function() operation, {
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? context,
    bool Function(AppException exception)? shouldRetry,
  }) async {
    int attempts = 0;
    AppException? lastException;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        attempts++;
        
        AppException exception;
        if (error is AppException) {
          exception = error;
        } else {
          exception = GenericException(
            message: error.toString(),
            stackTrace: stackTrace,
          );
        }

        lastException = exception;

        // Verifica se deve tentar novamente
        final shouldRetryNow = shouldRetry?.call(exception) ?? 
                               ExceptionUtils.isRecoverable(exception);

        if (!shouldRetryNow || attempts >= maxRetries) {
          handleException(exception, context: '$context (after $attempts attempts)');
          throw exception;
        }

        // Espera antes da próxima tentativa
        if (attempts < maxRetries) {
          await Future.delayed(delay * attempts);
        }
      }
    }

    // Se chegou aqui, todas as tentativas falharam
    final finalException = lastException!;
    handleException(
      finalException, 
      context: '$context (after $maxRetries attempts - all failed)'
    );
    throw finalException;
  }

  /// Valida dados e lança exceção se inválido
  void validate<T>(
    T value,
    bool Function(T) validator, {
    String? fieldName,
    String? errorMessage,
    String? context,
  }) {
    try {
      if (!validator(value)) {
        final exception = ValidationException(
          message: errorMessage ?? 'Validation failed for $fieldName',
          field: fieldName,
          value: value,
        );
        handleException(exception, context: context);
        throw exception;
      }
    } catch (e) {
      if (e is ValidationException) {
        handleException(e, context: context);
        rethrow;
      } else {
        final exception = ValidationException(
          message: errorMessage ?? 'Validation failed for $fieldName',
          field: fieldName,
          value: value,
        );
        handleException(exception, context: context);
        throw exception;
      }
    }
  }

  /// Verifica estado e lança exceção se inválido
  void checkState(
    bool condition,
    String errorMessage, {
    String? currentState,
    String? expectedState,
    String? transition,
    String? context,
  }) {
    if (!condition) {
      final exception = StateException(
        message: errorMessage,
        currentState: currentState,
        expectedState: expectedState,
        transition: transition,
      );
      handleException(exception, context: context);
      throw exception;
    }
  }

  /// Limpa recursos (para testes)
  void dispose() {
    _onError = null;
  }
}


/// Extension para facilitar tratamento de exceções
extension ExceptionHandling on Future {
  /// Trata erro em Future com valor padrão
  Future<T?> handleError<T>({
    T? defaultValue,
    String? context,
    void Function(AppException exception)? onError,
  }) async {
    try {
      return await this as T;
    } catch (error, stackTrace) {
      AppException exception;
      
      if (error is AppException) {
        exception = error;
      } else {
        exception = GenericException(
          message: error.toString(),
          stackTrace: stackTrace,
        );
      }

      onError?.call(exception);
      ErrorHandler.instance.handleException(exception, context: context);
      return defaultValue;
    }
  }

  /// Trata erro em Future com retry
  Future<T> handleErrorWithRetry<T>({
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? context,
    bool Function(AppException exception)? shouldRetry,
  }) async {
    return ErrorHandler.instance.executeWithRetryAsync<T>(
      () => this as Future<T>,
      maxRetries: maxRetries,
      delay: delay,
      context: context,
      shouldRetry: shouldRetry,
    );
  }
}

/// Extension para facilitar tratamento de exceções síncronas
extension SyncExceptionHandling<T> on T Function() {
  /// Trata erro com valor padrão
  T? handleError({
    T? defaultValue,
    String? context,
    void Function(AppException exception)? onError,
  }) {
    try {
      return this();
    } catch (error, stackTrace) {
      AppException exception;
      
      if (error is AppException) {
        exception = error;
      } else {
        exception = GenericException(
          message: error.toString(),
          stackTrace: stackTrace,
        );
      }

      onError?.call(exception);
      ErrorHandler.instance.handleException(exception, context: context);
      return defaultValue;
    }
  }

  /// Trata erro com retry
  T handleErrorWithRetry({
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 1),
    String? context,
    bool Function(AppException exception)? shouldRetry,
  }) {
    return ErrorHandler.instance.executeWithRetry<T>(
      this,
      maxRetries: maxRetries,
      delay: delay,
      context: context,
      shouldRetry: shouldRetry,
    );
  }
}
