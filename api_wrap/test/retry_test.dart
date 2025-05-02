import 'dart:async';

import 'package:api_wrap/src/retry/retry.dart';
import 'package:api_wrap/src/retry/delay_stategy.dart';
import 'package:api_wrap/src/retry/retry_if.dart';
import 'package:api_wrap/src/retry/retry_options.dart';
import 'package:api_wrap/src/retry/retry_stats.dart';
import 'package:test/test.dart' hide Retry;

void main() {
  group('Retry Constructor Validation', () {
    test('accepts valid maxAttempts', () {
      expect(() => Retry(maxAttempts: 1), returnsNormally);
      expect(() => Retry(maxAttempts: 10), returnsNormally);
      expect(() => Retry(maxAttempts: 100), returnsNormally);
    });

    test('rejects invalid maxAttempts', () {
      expect(() => Retry(maxAttempts: 0), throwsA(isA<AssertionError>()));
      expect(() => Retry(maxAttempts: -1), throwsA(isA<AssertionError>()));
      expect(() => Retry(maxAttempts: -100), throwsA(isA<AssertionError>()));
    });
  });

  group('Basic Retry Functionality', () {
    test('succeeds on first attempt', () async {
      var attempts = 0;
      final retry = Retry(maxAttempts: 3);

      final result = await retry.execute((stats) {
        attempts++;
        return 'Success';
      });

      expect(result, equals('Success'));
      expect(attempts, equals(1));
    });

    test('succeeds after retries', () async {
      var attempts = 0;
      final retry = Retry(
        maxAttempts: 3,
        delayFactor: Duration.zero,
      );

      final result = await retry.execute((stats) {
        attempts++;
        if (attempts < 3) throw Exception('Test error');
        return 'Success';
      });

      expect(result, equals('Success'));
      expect(attempts, equals(3));
    });

    test('throws when all retries exhausted', () async {
      var attempts = 0;
      final retry = Retry(
        maxAttempts: 3,
        delayFactor: Duration.zero,
      );

      final future = retry.execute((stats) {
        attempts++;
        throw Exception('Test error $attempts');
      });

      await expectLater(future, throwsA(isA<Exception>()));
      expect(attempts, equals(3));
    });

    test('handles async operations correctly', () async {
      var attempts = 0;
      final retry = Retry(
        maxAttempts: 3,
        delayFactor: Duration.zero,
      );

      final result = await retry.execute((stats) async {
        attempts++;
        await Future.delayed(Duration(milliseconds: 10));
        if (attempts < 3) throw Exception('Test error');
        return 'Success';
      });

      expect(result, equals('Success'));
      expect(attempts, equals(3));
    });
  });

  group('RetryIf Conditions', () {
    test('retries based on custom condition', () async {
      var attempts = 0;
      final retry = Retry(
        maxAttempts: 5,
        delayFactor: Duration.zero,
        retryIf: (error, stackTrace, stats) {
          // Only retry on even attempt numbers
          return stats.attempt < 2;
        },
      );

      await expectLater(
        () => retry.execute((stats) {
          attempts++;
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      expect(attempts, equals(2));
    });

    test('retries based on error type', () async {
      var attempts = 0;
      final retry = Retry(
        maxAttempts: 5,
        delayFactor: Duration.zero,
        retryIf: (error, stackTrace, stats) {
          return error is StateError;
        },
      );

      await expectLater(
        () => retry.execute((stats) {
          attempts++;
          if (attempts == 1) throw StateError('Retry this');
          throw ArgumentError('Do not retry this');
        }),
        throwsA(isA<ArgumentError>()),
      );

      expect(attempts, equals(2));
    });

    test('works with async retryIf condition', () async {
      var attempts = 0;
      final retry = Retry(
        maxAttempts: 5,
        delayFactor: Duration.zero,
        retryIf: (error, stackTrace, stats) async {
          await Future.delayed(Duration(milliseconds: 10));
          return attempts < 3;
        },
      );

      await expectLater(
        () => retry.execute((stats) {
          attempts++;
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      expect(attempts, equals(3));
    });

    test('never retries with RetryIf.never', () async {
      var attempts = 0;
      final retry = Retry(
        maxAttempts: 5,
        retryIf: RetryIf.never,
      );

      await expectLater(
        () => retry.execute((stats) {
          attempts++;
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      expect(attempts, equals(1));
    });

    test('always retries with RetryIf.always', () async {
      var attempts = 0;
      final retry = Retry(
        maxAttempts: 3,
        delayFactor: Duration.zero,
        retryIf: RetryIf.always,
      );

      await expectLater(
        () => retry.execute((stats) {
          attempts++;
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      expect(attempts, equals(3));
    });
  });

  group('Time Limits', () {
    test('respects maxTotalTime - stops after time limit', () async {
      var attempts = 0;
      final stopwatch = Stopwatch()..start();

      final retry = Retry(
        maxAttempts: 100, // Large number to focus on time limit
        delayFactor: Duration.zero,
        maxTotalTime: Duration(milliseconds: 700),
      );

      await expectLater(
        () => retry.execute((stats) async {
          attempts++;
          await Future.delayed(Duration(milliseconds: 300));
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );
      stopwatch.stop();

      // Should stop after time limit, not make all attempts
      expect(attempts, 3);
      // Should be close to maxTotalTime but could exceed a bit due to async overhead
      expect(stopwatch.elapsed, lessThan(Duration(milliseconds: 950)));
      expect(stopwatch.elapsed, greaterThan(Duration(milliseconds: 900)));
    });

    test('last attempt can exceed maxTotalTime', () async {
      var attempts = 0;
      final stopwatch = Stopwatch()..start();

      final retry = Retry(
        maxAttempts: 100,
        delayFactor: Duration.zero,
        maxTotalTime: Duration(milliseconds: 250),
      );

      await expectLater(
        () => retry.execute((stats) async {
          attempts++;
          // Long-running operation that exceeds maxTotalTime
          await Future.delayed(Duration(milliseconds: 200));
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );
      stopwatch.stop();

      expect(attempts, 2);
      // Should exceed maxTotalTime due to last attempt
      expect(stopwatch.elapsed, greaterThan(Duration(milliseconds: 400)));
      expect(stopwatch.elapsed, lessThan(Duration(milliseconds: 450)));
    });

    test('combines maxAttempts with maxTotalTime', () async {
      var attempts = 0;

      final retry = Retry(
        maxAttempts: 2,
        delayFactor: Duration.zero,
        maxTotalTime: Duration(milliseconds: 1000),
      );

      await expectLater(
        () => retry.execute((stats) async {
          attempts++;
          await Future.delayed(Duration(milliseconds: 100));
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      // Should stop after maxAttempts, not time limit
      expect(attempts, equals(2));
    });
  });

  group('Delay Strategies', () {
    test('zero delay strategy skips all delays, run synchronously', () async {
      var attempts = 0;
      final stopwatch = Stopwatch()..start();

      final retry = Retry(
        maxAttempts: 3,
        delayStrategy: DelayStrategy.zero,
      );

      expect(
        () => retry.execute((stats) {
          attempts++;
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      stopwatch.stop();

      expect(attempts, equals(3));
      // No delays, no await, should be very fast
      expect(stopwatch.elapsed, lessThan(Duration(milliseconds: 50)));
    });

    test('exponential delay increases with each attempt', () async {
      final delays = <Duration>[];

      final retry = Retry(
        maxAttempts: 4,
        delayFactor: Duration(milliseconds: 100),
        randomizationFactor: 0, // Disable randomization for predictable results
        delayStrategy: DelayStrategy.exponential,
      );

      await expectLater(
        () => retry.execute((stats) {
          delays.add(stats.delayBeforeNextAttempt);
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      expect(delays.length, equals(4));
      // Each delay should be significantly larger than the previous
      for (int i = 1; i < delays.length; i++) {
        expect(delays[i].inMilliseconds > delays[i - 1].inMilliseconds * 1.5,
            isTrue);
      }
    });

    test('linear delay increases proportionally', () async {
      final delays = <Duration>[];

      final retry = Retry(
        maxAttempts: 4,
        delayFactor: Duration(milliseconds: 100),
        randomizationFactor: 0,
        delayStrategy: DelayStrategy.linear,
      );

      await expectLater(
        () => retry.execute((stats) {
          delays.add(stats.delayBeforeNextAttempt);
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      expect(delays.length, equals(4));

      // Check that differences between consecutive delays are approximately equal
      final diff1 = delays[1].inMilliseconds - delays[0].inMilliseconds;
      final diff2 = delays[2].inMilliseconds - delays[1].inMilliseconds;
      final diff3 = delays[3].inMilliseconds - delays[2].inMilliseconds;

      expect((diff2 - diff1).abs(), 0);
      expect((diff3 - diff2).abs(), 0);
    });

    test('constant delay produces identical delays', () async {
      final delays = <Duration>[];

      final retry = Retry(
        maxAttempts: 4,
        delayFactor: Duration(milliseconds: 100),
        randomizationFactor: 0,
        delayStrategy: DelayStrategy.fixed,
      );

      await expectLater(
        () => retry.execute((stats) {
          delays.add(stats.delayBeforeNextAttempt);
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      expect(delays.length, equals(4));
      // All delays should be identical
      expect(delays[0], equals(delays[1]));
      expect(delays[1], equals(delays[2]));
      expect(delays[2], equals(delays[3]));
    });

    test('respects minDelay and maxDelay bounds', () async {
      final delays = <Duration>[];

      final retry = Retry(
        maxAttempts: 10,
        delayFactor: Duration(milliseconds: 100),
        minDelay: Duration(milliseconds: 200),
        maxDelay: Duration(milliseconds: 500),
        randomizationFactor: 0.25,
        delayStrategy: DelayStrategy.exponential,
      );

      await expectLater(
        () => retry.execute((stats) {
          delays.add(stats.delayBeforeNextAttempt);
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      // First delay should respect minDelay
      expect(delays.first.inMilliseconds, greaterThanOrEqualTo(200));

      // Later delays should be capped at maxDelay
      expect(delays.last.inMilliseconds, lessThanOrEqualTo(500));
    });
  });

  group('Event Handlers', () {
    test('onAttempt handler receives correct stats', () async {
      final attemptStats = <RetryStats>[];

      final retry = Retry(
        maxAttempts: 3,
        delayFactor: Duration.zero,
        onAttempt: (stats) {
          attemptStats.add(stats);
        },
      );

      await expectLater(
        () => retry.execute((stats) {
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      expect(attemptStats.length, equals(3));

      // Check attempt counters
      expect(attemptStats[0].attempt, equals(1));
      expect(attemptStats[1].attempt, equals(2));
      expect(attemptStats[2].attempt, equals(3));

      // Check that time is increasing
      expect(attemptStats[0].elapsedTime < attemptStats[1].elapsedTime, isTrue);
      expect(attemptStats[1].elapsedTime < attemptStats[2].elapsedTime, isTrue);
    });

    test('onFailAttempt handler receives correct error and stats', () async {
      final errors = <Object>[];
      final stackTraces = <StackTrace>[];
      final failStats = <RetryStats>[];

      final retry = Retry(
        maxAttempts: 2,
        delayFactor: Duration.zero,
        onFailAttempt: (error, stackTrace, stats) {
          errors.add(error);
          stackTraces.add(stackTrace);
          failStats.add(stats);
        },
      );

      final testError = StateError('Test error');

      await expectLater(
        () => retry.execute((stats) {
          throw testError;
        }),
        throwsA(same(testError)), // Should be the exact same error instance
      );

      // В реальности onFailAttempt вызывается два раза
      expect(errors.length, equals(2));
      expect(errors[0], same(testError));
      expect(stackTraces.length, equals(2));
      expect(failStats.length, equals(2));
      expect(failStats[0].attempt, equals(1));
    });

    test('willRetry is correctly set in stats', () async {
      final retryFlags = <bool?>[];

      final retry = Retry(
        maxAttempts: 3,
        delayFactor: Duration.zero,
        onFailAttempt: (error, stackTrace, stats) {
          retryFlags.add(stats.willRetry);
        },
      );

      await expectLater(
        () => retry.execute((stats) {
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      // onFailAttempt вызывается для всех попыток
      expect(retryFlags.length, equals(3));
      expect(retryFlags[0], isTrue); // First attempt will retry
      expect(retryFlags[1], isTrue); // Second attempt will retry
      expect(retryFlags[2],
          isFalse); // Third attempt won't retry (will be the last)
    });
  });

  group('Factory Constructors and Options', () {
    test('Retry.none() never retries', () async {
      var attempts = 0;
      final retry = Retry.none();

      await expectLater(
        () => retry.execute((stats) {
          attempts++;
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      expect(attempts, equals(1));
    });

    test('Retry.byOptions uses provided options', () async {
      var attempts = 0;
      final options = RetryOptions(
        maxAttempts: 3,
        delayFactor: Duration.zero,
        maxTotalTime: Duration(seconds: 1),
      );

      final retry = Retry.byOptions(
        options: options,
      );

      await expectLater(
        () => retry.execute((stats) {
          attempts++;
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );

      expect(attempts, equals(3));
      expect(retry.options,
          same(options)); // Should be the exact same options instance
    });

    test('handles extremely large maxAttempts', () async {
      var attempts = 0;
      final retry = Retry(
        maxAttempts: 1000000, // Absurdly large
        delayFactor: Duration.zero,
        maxTotalTime: Duration(milliseconds: 400), // But limited by time
      );

      final stopwatch = Stopwatch()..start();
      await expectLater(
        () => retry.execute((stats) async {
          attempts++;
          await Future.delayed(Duration(milliseconds: 25));
          throw Exception('Test error');
        }),
        throwsA(isA<Exception>()),
      );
      stopwatch.stop();

      // Should be limited by time, not attempts
      expect(attempts, greaterThan(14));
      expect(attempts, lessThan(16));
      expect(stopwatch.elapsed, lessThan(Duration(milliseconds: 450)));
    });
  });

  group('Edge Cases', () {
    test('handles recursive retries', () async {
      var outerAttempts = 0;
      var innerAttempts = 0;

      final retry = Retry(
        maxAttempts: 3,
        delayFactor: Duration.zero,
      );

      await expectLater(
        () => retry.execute((outerStats) {
          outerAttempts++;

          return retry.execute((innerStats) {
            innerAttempts++;
            throw Exception('Inner error');
          });
        }),
        throwsA(isA<Exception>()),
      );

      expect(outerAttempts, equals(3));
      expect(innerAttempts, equals(9)); // 3 outer attempts × 3 inner attempts
    });

    test('resets stopwatch on completion', () async {
      // This tests that the stopwatch is properly stopped to avoid resource leaks
      var attempts = 0;
      final retry = Retry(
        maxAttempts: 3,
        delayFactor: Duration.zero,
      );

      final result = await retry.execute((stats) {
        attempts++;
        if (attempts < 3) throw Exception('Test error');
        return stats.elapsedTime; // Return the elapsed time
      });

      // The returned elapsed time should be non-zero
      expect(result, isA<Duration>());
      expect(result.inMicroseconds, greaterThan(0));

      // Wait to ensure stopwatch would have continued if not stopped
      await Future.delayed(Duration(milliseconds: 50));

      // Make a new call to verify stopwatch was reset
      final newResult = await retry.execute((stats) {
        return stats.elapsedTime;
      });

      // The new elapsed time should be small, not including time since last call
      expect(newResult.inMilliseconds, lessThan(20));
    });
  });

  group('Cancel Retry Operations', () {
    test('cancel semantics with and without key', () async {
      final retry = Retry(maxAttempts: 3);

      // Check the current implementation's behavior for empty retry set
      final wasCancelledEmpty = retry.cancelRetry();
      // Current implementation возвращает false для пустого множества операций
      expect(wasCancelledEmpty, isFalse);

      // Try to cancel non-existent operation
      final wasNonExistentCancelled = retry.cancelRetry(key: 'non-existent');
      expect(wasNonExistentCancelled, isFalse);
    });

    test('cancelRetry prevents further retry attempts', () async {
      var attempts = 0;
      final retry = Retry(
        maxAttempts: 10, // High number to ensure we'd continue without cancel
        delayFactor: Duration.zero,
      );

      // Launch the retry operation with a key
      final future = retry.execute(
        (stats) async {
          attempts++;

          // Wait a bit to give time for cancellation to take effect
          await Future.delayed(Duration(milliseconds: 50));

          // Always throw to trigger retry
          throw Exception('Test error $attempts');
        },
        key: 'operation-to-cancel',
      );

      // Cancel the operation
      final wasCancelled = retry.cancelRetry(key: 'operation-to-cancel');
      expect(wasCancelled, isTrue);

      // The operation should fail
      await expectLater(future, throwsA(isA<Exception>()));

      expect(attempts, 1);
    });

    test('cancelRetry with null key cancels all operations', () async {
      var attemptsA = 0;
      var attemptsB = 0;
      final retry = Retry(
        maxAttempts: 10,
        delayFactor: Duration.zero,
      );

      final futureA = retry.execute(
        (stats) async {
          attemptsA++;

          await Future.delayed(Duration(milliseconds: 50));
          throw Exception('Test error A $attemptsA');
        },
        key: 'operation-A',
      );

      final futureB = retry.execute(
        (stats) async {
          attemptsB++;

          await Future.delayed(Duration(milliseconds: 50));
          throw Exception('Test error B $attemptsB');
        },
        key: 'operation-B',
      );

      final wasCancelled = retry.cancelRetry();

      expect(wasCancelled, isTrue);

      // Both operations should fail
      await expectLater(futureA, throwsA(isA<Exception>()));
      await expectLater(futureB, throwsA(isA<Exception>()));

      // Both should have limited attempts due to cancellation
      // С учетом асинхронности и того, что текущая попытка еще выполняется
      expect(attemptsA, 1);
      expect(attemptsB, 1);
    });

    test('retryIsCanceled flag is set in stats after cancellation', () async {
      bool? canceledFlagSeen;

      final retry = Retry(
        maxAttempts: 5,
        delayFactor: Duration.zero,
        onFailAttempt: (e, s, stats) {
          canceledFlagSeen ??= stats.retryIsCancaled;
        },
      );

      // Launch operation that will check retryIsCancaled flag
      final future = retry.execute(
        (_) async {
          await Future.delayed(Duration(milliseconds: 20));

          // Имитируем работу
          throw Exception('Test error');
        },
        key: 'operation-to-check',
      );

      // Отменяем операцию
      retry.cancelRetry(key: 'operation-to-check');

      await expectLater(future, throwsException);

      expect(canceledFlagSeen, isTrue);
    });

    test('multiple retry operations', () async {
      // Test that multiple operations can run independently
      final retry = Retry(
        maxAttempts: 2,
        delayFactor: Duration.zero,
      );

      var attemptsA = 0;
      var attemptsB = 0;

      // Helper functions to run operations
      Future<String> runOpA() async {
        try {
          return await retry.execute<String>(
            (stats) {
              attemptsA++;
              throw Exception('Test error A');
            },
          );
        } catch (e) {
          return 'Error A';
        }
      }

      Future<String> runOpB() async {
        try {
          return await retry.execute<String>(
            (stats) {
              attemptsB++;
              if (attemptsB < 2) {
                throw Exception('Test error B - first attempt');
              }
              return 'Success B';
            },
          );
        } catch (e) {
          return 'Error B';
        }
      }

      // Run operations
      final results = await Future.wait([runOpA(), runOpB()]);

      // Operation A should fail after max attempts
      expect(results[0], equals('Error A'));
      expect(attemptsA, equals(2));

      // Operation B should succeed on second attempt
      expect(results[1], equals('Success B'));
      expect(attemptsB, equals(2));
    });

    test('cancelRetry stops specific operations by key while others continue',
        () async {
      // Test multiple operations with selective cancellation
      final retry = Retry(
        maxAttempts:
            10, // Large value to ensure operations would continue without cancellation
        delayFactor: Duration.zero,
      );

      var attemptsA = 0;
      var attemptsB = 0;
      var attemptsC = 0;

      final delay = Duration(milliseconds: 20);

      // Helper functions to create futures with proper error handling
      Future<String> runOperationA() async {
        try {
          return await retry.execute(
            (stats) async {
              attemptsA++;
              await Future.delayed(delay);
              throw Exception('Operation A error');
            },
            key: 'key-A',
          );
        } catch (e) {
          return 'A failed with $attemptsA attempts';
        }
      }

      Future<String> runOperationB() async {
        try {
          return await retry.execute(
            (stats) async {
              attemptsB++;
              await Future.delayed(delay);
              throw Exception('Operation B error');
            },
            key: 'key-B',
          );
        } catch (e) {
          return 'B failed with $attemptsB attempts';
        }
      }

      Future<String> runOperationC() async {
        try {
          return await retry.execute(
            (stats) async {
              attemptsC++;
              await Future.delayed(delay);
              throw Exception('Operation C error');
            },
            key: 'key-C',
          );
        } catch (e) {
          return 'C failed with $attemptsC attempts';
        }
      }

      // Run three operations simultaneously with different keys
      final futureA = runOperationA();
      final futureB = runOperationB();
      final futureC = runOperationC();

      // Cancel only operations A and B
      final cancelledA = retry.cancelRetry(key: 'key-A');

      await Future.delayed(delay * 2.5);

      final cancelledB = retry.cancelRetry(key: 'key-B');

      // Wait for all operations to complete
      final results = await Future.wait([futureA, futureB, futureC]);

      // Verify cancellation results
      expect(cancelledA, isTrue);
      expect(cancelledB, isTrue);

      expect(attemptsA, 1);
      expect(attemptsB, 3);
      expect(attemptsC, 10); // Should run to max attempts

      expect(results[0].contains('A failed with'), isTrue);
      expect(results[1].contains('B failed with'), isTrue);
      expect(results[2].contains('C failed with'), isTrue);
    });
  });
}
