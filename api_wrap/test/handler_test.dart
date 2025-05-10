import 'dart:async';

import 'package:dio/dio.dart';
import 'package:handler/handler.dart';
import 'package:handler/src/operations_container.dart';
import 'package:test/test.dart' hide Retry;

void main() {
  group('Handler', () {
    late Handler<Map<String, dynamic>> handler;
    late OperationsContainer container;

    setUp(() {
      container = OperationsContainer();
      handler = Handler<Map<String, dynamic>>(
        parseBaseResponseError: (data) => data as Map<String, dynamic>,
        container: container,
      );
    });

    test('should be created with correct parameters', () {
      final retry = Retry(maxAttempts: 3);

      final customHandler = Handler<Map<String, dynamic>>(
        parseBaseResponseError: (data) => data as Map<String, dynamic>,
        retry: retry,
        container: container,
        onError: (HandledError<Map<String, dynamic>> error) {},
      );

      expect(customHandler, isA<Handler<Map<String, dynamic>>>());
    });

    test(
        'should throw if parseBaseResponseError is not provided with non-dynamic error type',
        () {
      expect(
        () => Handler<Map<String, dynamic>>(),
        throwsArgumentError,
      );
    });

    group('handle method', () {
      test('should execute a function and return its result', () async {
        final result = await handler.handle<int, int>(
          () => 42,
        );

        expect(result, 42);
      });

      test('should transform result with onSuccess callback', () async {
        final result = await handler.handle<int, String>(
          () => 42,
          onSuccess: (res) => 'Value: $res',
        );

        expect(result, 'Value: 42');
      });

      test('should handle errors with onError callback', () async {
        final result = await handler.handle<int, String>(
          () => throw Exception('Test error'),
          onError: (error) => 'Error caught',
        );

        expect(result, 'Error caught');
      });

      test('should use provided retry policy', () async {
        int attempts = 0;
        final retry = Retry(
          maxAttempts: 3,
          onAttempt: (_) {},
          onAttemptFail: (_, __, ___) {},
        );

        await handler.handle<int, int>(
          () {
            attempts++;
            if (attempts < 3) {
              throw Exception('Fail');
            }
            return 42;
          },
          retry: retry,
        );

        expect(attempts, 3);
      });

      test('should apply rate limiting', () async {
        final completer = Completer<void>();
        int executionCount = 0;

        // Create a debounce rate limiter with 100ms delay
        final rateLimiter = RateLimiter.debounce(
          duration: Duration(milliseconds: 100),
          onDelayEnd: () {
            completer.complete();
          },
        );

        // Execute the function through the handler with rate limiting
        handler.handle<int, int>(
          () {
            executionCount++;
            return 42;
          },
          key: 'debounce-test',
          rateLimiter: rateLimiter,
        );

        // Execution should be delayed
        expect(executionCount, 0);

        // Wait for the delay to complete
        await completer.future;

        // Function should have executed once
        expect(executionCount, 1);
      });
    });

    group('handleStrict method', () {
      test('should always return non-null value on success', () async {
        final result = await handler.handleStrict<int, int>(
          () => 42,
          onSuccess: (res) => res,
        );

        expect(result, 42);
      });

      test('should throw on error if no onError provided', () async {
        expect(
          () => handler.handleStrict<int, int>(
            () => throw Exception('Test error'),
            onSuccess: (res) => res,
          ),
          throwsA(isA<HandledError<Map<String, dynamic>>>()),
        );
      });
    });

    group('wrapError method', () {
      test('should wrap DioException as ErrorResponse', () {
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            requestOptions: RequestOptions(path: '/test'),
            statusCode: 400,
            data: {'message': 'Bad request'},
          ),
        );

        final wrappedError = handler.wrapError(dioError, StackTrace.current);

        expect(wrappedError, isA<ErrorResponse<Map<String, dynamic>>>());
        expect(
          (wrappedError as ErrorResponse<Map<String, dynamic>>).error,
          {'message': 'Bad request'},
        );
      });

      test('should wrap generic exception as InternalError', () {
        final error = Exception('Test error');
        final wrappedError = handler.wrapError(error, StackTrace.current);

        expect(wrappedError, isA<InternalError<Map<String, dynamic>>>());
        expect(
          (wrappedError as InternalError<Map<String, dynamic>>).error,
          error,
        );
      });

      test('should keep HandledError as is', () {
        final originalError = InternalError<Map<String, dynamic>>(
          error: Exception('Original error'),
          stackTrace: StackTrace.current,
        );

        final wrappedError =
            handler.wrapError(originalError, StackTrace.current);

        expect(wrappedError, equals(originalError));
      });
    });

    group('fire and cancel methods', () {
      late Completer<void> operationExecuted;
      late RateLimiter rateLimiter;
      final testKey = 'test-operation';

      setUp(() {
        operationExecuted = Completer<void>();
        rateLimiter = RateLimiter.debounce(
          duration: Duration(milliseconds: 100),
        );
      });

      test('should fire a specific debounce operation immediately', () async {
        int executionCount = 0;

        // Create an operation with debounce rate limiter
        handler.handle<int, int>(
          () {
            executionCount++;
            operationExecuted.complete();
            return 42;
          },
          key: testKey,
          rateLimiter: rateLimiter,
        );

        // Operation should not have executed yet due to debounce
        expect(executionCount, 0);

        // Fire the operation immediately
        await handler.fire(key: testKey);

        // Operation should have executed
        expect(executionCount, 1);
      });

      test('should fire all debounce operations immediately', () async {
        int operation1Count = 0;
        int operation2Count = 0;
        final operation1Complete = Completer<void>();
        final operation2Complete = Completer<void>();

        // Create two operations with debounce rate limiters
        handler.handle<int, int>(
          () {
            operation1Count++;
            operation1Complete.complete();
            return 42;
          },
          key: 'op1',
          rateLimiter: rateLimiter,
        );

        handler.handle<int, int>(
          () {
            operation2Count++;
            operation2Complete.complete();
            return 24;
          },
          key: 'op2',
          rateLimiter: rateLimiter,
        );

        // Operations should not have executed yet
        expect(operation1Count, 0);
        expect(operation2Count, 0);

        // Fire all operations
        await handler.fireAll();

        // Wait for both operations to complete
        await Future.wait(
            [operation1Complete.future, operation2Complete.future]);

        // Both operations should have executed
        expect(operation1Count, 1);
        expect(operation2Count, 1);
      });

      test('should cancel a specific operation', () async {
        int executionCount = 0;
        final executionDelayCompleter = Completer<void>();

        // Create an operation with debounce
        handler.handle<int, int>(
          () async {
            // Wait for signal before continuing
            await executionDelayCompleter.future;
            executionCount++;
            return 42;
          },
          key: testKey,
          rateLimiter: rateLimiter,
        );

        // Cancel the operation before it executes
        handler.cancel(key: testKey);

        // Allow the operation to continue if it wasn't cancelled
        executionDelayCompleter.complete();

        // Wait to ensure any potential execution would have completed
        await Future.delayed(Duration(milliseconds: 200));

        // Operation should not have executed
        expect(executionCount, 0);
      });

      test('should cancel all operations', () async {
        int operation1Count = 0;
        int operation2Count = 0;
        final executionDelayCompleter = Completer<void>();

        // Create two operations
        handler.handle<int, int>(
          () async {
            await executionDelayCompleter.future;
            operation1Count++;
            return 42;
          },
          key: 'op1',
          rateLimiter: rateLimiter,
        );

        handler.handle<int, int>(
          () async {
            await executionDelayCompleter.future;
            operation2Count++;
            return 24;
          },
          key: 'op2',
          rateLimiter: rateLimiter,
        );

        // Cancel all operations
        handler.cancelAll();

        // Allow operations to continue if they weren't cancelled
        executionDelayCompleter.complete();

        // Wait to ensure any potential execution would have completed
        await Future.delayed(Duration(milliseconds: 200));

        // Neither operation should have executed
        expect(operation1Count, 0);
        expect(operation2Count, 0);
      });

      test('should cancel throttle cooldown with fire', () async {
        final throttler = RateLimiter.throttle(
          duration: Duration(milliseconds: 500),
        );
        int executionCount = 0;

        // First execution
        await handler.handle<int, int>(
          () {
            executionCount++;
            return 42;
          },
          key: testKey,
          rateLimiter: throttler,
        );

        expect(executionCount, 1);

        // This should be throttled (not executed)
        await handler.handle<int, int>(
          () {
            executionCount++;
            return 42;
          },
          key: testKey,
          rateLimiter: throttler,
        );

        expect(executionCount, 1); // Still 1, because throttled

        // Cancel the cooldown
        await handler.fire(key: testKey);

        // Now another call should execute
        await handler.handle<int, int>(
          () {
            executionCount++;
            return 42;
          },
          key: testKey,
          rateLimiter: throttler,
        );

        expect(executionCount, 2); // Should be 2 now
      });
    });

    group('integration tests', () {
      test('handle with delays, retry and rate limiting', () async {
        final stopwatch = Stopwatch()..start();
        int attemptCount = 0;
        int executionCount = 0;

        final retry = Retry(
          maxAttempts: 3,
          delayFactor: Duration(milliseconds: 50),
        );

        final rateLimiter = RateLimiter.debounce(
          duration: Duration(milliseconds: 50),
        );

        final result = await handler.handle<int, String>(
          () {
            attemptCount++;
            if (attemptCount < 2) {
              throw Exception('Simulated failure');
            }
            executionCount++;
            return 42;
          },
          delay: Duration(milliseconds: 50),
          minExecutionTime: Duration(milliseconds: 100),
          retry: retry,
          rateLimiter: rateLimiter,
          onSuccess: (res) => 'Success: $res',
          onError: (error) => 'Error: ${error.toString()}',
        );

        stopwatch.stop();

        expect(result, 'Success: 42');
        expect(attemptCount, 2); // One failure, one success
        expect(executionCount, 1);

        // Проверяем, что общее время выполнения находится в разумных пределах
        // Из-за вариативности времени выполнения в разных окружениях
        // используем более гибкую проверку
        expect(stopwatch.elapsedMilliseconds, greaterThan(200));
      });
    });
  });
}
