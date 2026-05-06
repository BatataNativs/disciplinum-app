import 'dart:async';
import 'package:disciplinum/core/logging/logger_service.dart';

/// Handler de retry com exponential backoff para tarefas background
/// 
/// Executa uma tarefa com retry automático em caso de falha,
/// aumentando o tempo de espera exponencialmente entre tentativas.
class BackgroundRetryHandler {
  /// Executa uma tarefa com retry exponencial
  /// 
  /// [task] - A função assíncrona a ser executada
  /// [maxRetries] - Número máximo de tentativas (padrão: 3)
  /// [initialDelay] - Delay inicial entre tentativas (padrão: 1 segundo)
  /// [taskName] - Nome da tarefa para logging
  /// 
  /// Retorna true se a tarefa foi executada com sucesso, false caso contrário
  static Future<bool> executeWithRetry(
    Future<void> Function() task, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    String taskName = 'background_task',
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        attempt++;
        LoggerService.instance.d('$taskName: Tentativa $attempt/$maxRetries');
        
        await task();
        
        if (attempt > 1) {
          LoggerService.instance.i('$taskName: Sucesso após $attempt tentativas');
        }
        return true;
      } catch (e) {
        if (attempt >= maxRetries) {
          LoggerService.instance.e(
            '$taskName: Falhou após $maxRetries tentativas',
            error: e,
          );
          return false;
        }

        LoggerService.instance.w(
          '$taskName: Falha na tentativa $attempt, retry em ${delay.inSeconds}s...',
          error: e,
        );
        
        await Future.delayed(delay);
        delay *= 2; // Exponential backoff: 1s → 2s → 4s
      }
    }

    return false;
  }

  /// Executa múltiplas tarefas sequencialmente com retry
  /// 
  /// Útil para verificar múltiplos módulos onde cada um pode falhar independentemente
  static Future<Map<String, bool>> executeBatchWithRetry(
    Map<String, Future<void> Function()> tasks, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    final results = <String, bool>{};

    for (final entry in tasks.entries) {
      final taskName = entry.key;
      final task = entry.value;

      results[taskName] = await executeWithRetry(
        task,
        maxRetries: maxRetries,
        initialDelay: initialDelay,
        taskName: taskName,
      );
    }

    return results;
  }

  /// Verifica se um erro é recuperável (merece retry)
  /// 
  /// Erros de network, timeout e busy são recuperáveis
  /// Erros de lógica/dados não são
  static bool isRecoverableError(dynamic error) {
    if (error == null) return false;
    
    final errorString = error.toString().toLowerCase();
    
    // Erros recuperáveis
    final recoverablePatterns = [
      'socket',
      'timeout',
      'connection',
      'network',
      'busy',
      'locked',
      'unavailable',
      'temporarily',
      'retry',
    ];
    
    for (final pattern in recoverablePatterns) {
      if (errorString.contains(pattern)) return true;
    }
    
    return false;
  }
}
