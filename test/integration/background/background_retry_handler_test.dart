import 'package:flutter_test/flutter_test.dart';
import 'package:disciplinum/core/background/background_retry_handler.dart';

void main() {
  group('BackgroundRetryHandler', () {
    test('should succeed on first attempt', () async {
      int attempts = 0;

      final result = await BackgroundRetryHandler.executeWithRetry(
        () async {
          attempts++;
        },
        maxRetries: 3,
        taskName: 'test_success',
      );

      expect(result, isTrue);
      expect(attempts, equals(1));
    });

    test('should succeed after retries', () async {
      int attempts = 0;

      final result = await BackgroundRetryHandler.executeWithRetry(
        () async {
          attempts++;
          if (attempts < 3) {
            throw Exception('Temporary failure');
          }
        },
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 10),
        taskName: 'test_retry_success',
      );

      expect(result, isTrue);
      expect(attempts, equals(3));
    });

    test('should fail after max retries', () async {
      int attempts = 0;

      final result = await BackgroundRetryHandler.executeWithRetry(
        () async {
          attempts++;
          throw Exception('Permanent failure');
        },
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 1),
        taskName: 'test_retry_fail',
      );

      expect(result, isFalse);
      expect(attempts, equals(3));
    });

    test('should execute batch with mixed results', () async {
      final results = await BackgroundRetryHandler.executeBatchWithRetry(
        {
          'task_success': () async {
            // Success
          },
          'task_fail': () async {
            throw Exception('Always fails');
          },
        },
        maxRetries: 2,
        initialDelay: const Duration(milliseconds: 1),
      );

      expect(results['task_success'], isTrue);
      expect(results['task_fail'], isFalse);
    });

    test('should identify recoverable errors', () {
      expect(
        BackgroundRetryHandler.isRecoverableError(Exception('Socket timeout')),
        isTrue,
      );
      expect(
        BackgroundRetryHandler.isRecoverableError(Exception('Connection refused')),
        isTrue,
      );
      expect(
        BackgroundRetryHandler.isRecoverableError(Exception('Network unavailable')),
        isTrue,
      );
      expect(
        BackgroundRetryHandler.isRecoverableError(Exception('Database locked')),
        isTrue,
      );
    });

    test('should identify non-recoverable errors', () {
      expect(
        BackgroundRetryHandler.isRecoverableError(Exception('Null pointer')),
        isFalse,
      );
      expect(
        BackgroundRetryHandler.isRecoverableError(Exception('Invalid argument')),
        isFalse,
      );
      expect(
        BackgroundRetryHandler.isRecoverableError(null),
        isFalse,
      );
    });
  });
}
