import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Serviço de logging profissional para o Disciplinum
/// Centraliza todos os logs do aplicativo com diferentes níveis
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  static LoggerService get instance => _instance;
  
  late final Logger _logger;
  
  LoggerService._internal() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: kReleaseMode ? ConsoleOutput() : MultiOutput([
        ConsoleOutput(),
        // Em produção, poderíamos adicionar FileOutput ou remote logging
      ]),
      filter: kReleaseMode ? ProductionFilter() : DevelopmentFilter(),
    );
  }

  /// Log nível debug - informações detalhadas para desenvolvimento
  void d(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Log nível info - informações gerais do aplicativo
  void i(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log nível warning - alertas que não são críticos
  void w(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log nível error - erros que precisam de atenção
  void e(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log específico para eventos de analytics
  void analytics(String event, Map<String, dynamic>? properties) {
    final props = properties != null ? ' | $properties' : '';
    _logger.i('📊 Analytics: $event$props');
  }

  /// Log específico para eventos de gamificação
  void gamification(String event, {Map<String, dynamic>? data}) {
    final eventData = data != null ? ' | $data' : '';
    _logger.i('🎮 Gamification: $event$eventData');
  }

  /// Log específico para eventos de usuário
  void user(String action, {String? userId, Map<String, dynamic>? context}) {
    final userContext = userId != null ? ' (user: $userId)' : '';
    final ctx = context != null ? ' | $context' : '';
    _logger.i('👤 User: $action$userContext$ctx');
  }

  /// Log específico para performance
  void performance(String operation, Duration duration, {Map<String, dynamic>? metadata}) {
    final meta = metadata != null ? ' | $metadata' : '';
    _logger.i('⚡ Performance: $operation in ${duration.inMilliseconds}ms$meta');
  }

  /// Log específico para erros de rede
  void network(String operation, String error, {int? statusCode}) {
    final status = statusCode != null ? ' [$statusCode]' : '';
    _logger.w('🌐 Network: $operation failed$status - $error');
  }

  /// Log específico para estado da UI
  void ui(String screen, String state, {Map<String, dynamic>? params}) {
    final parameters = params != null ? ' | $params' : '';
    _logger.d('🖥️ UI: $screen -> $state$parameters');
  }

  /// Log específico para eventos do sistema
  void system(String event, {Map<String, dynamic>? details}) {
    final eventDetails = details != null ? ' | $details' : '';
    _logger.i('⚙️ System: $event$eventDetails');
  }

  /// Log para medir performance de operações
  T measure<T>(String operation, T Function() block) {
    final stopwatch = Stopwatch()..start();
    try {
      final result = block();
      stopwatch.stop();
      performance(operation, stopwatch.elapsed);
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      LoggerService.instance.e('Performance measurement failed for $operation', 
         error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Log para medir performance de operações assíncronas
  Future<T> measureAsync<T>(String operation, Future<T> Function() block) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await block();
      stopwatch.stop();
      performance(operation, stopwatch.elapsed);
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      LoggerService.instance.e('Async performance measurement failed for $operation', 
         error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Filter personalizado para ambiente de desenvolvimento
class DevelopmentFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Em desenvolvimento, log tudo
    return true;
  }
}

/// Filter personalizado para ambiente de produção
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Em produção, só log warnings e errors
    return event.level.value >= Level.warning.value;
  }
}

/// Output personalizado para console
class ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      if (kDebugMode) {
        print(line); // Em modo debug, usa print normal
      } else {
        // Em produção, poderia integrar com Firebase Crashlytics
        // ou outro serviço de logging remoto
        // Usando o logger framework em vez de print direto
      }
    }
  }
}
