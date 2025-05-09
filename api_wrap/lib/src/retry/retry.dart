import 'dart:async';

import 'delay_stategy.dart';
import 'retry_if.dart';
import 'retry_options.dart';
import 'retry_stats.dart';

/// A class that manages retry attempts for operations that may fail.
///
/// The retry mechanism is controlled by several key components:
/// - Delay strategy: Determines the timing between retry attempts
/// - Retry conditions: Custom logic to decide if a retry should be attempted
/// - Event handlers: Callbacks for monitoring retry progress
///
/// Note: [maxTotalTime] does not include the last attempt's execution time,
/// so the total time might exceed this limit by the duration of the final attempt.
///
/// For custom retry logic with delays, use [DelayStrategy.zero] or set [maxDelay] to [Duration.zero]
/// in combination with [retryIf] to implement your own retry logic.
///
/// Example:
/// ```dart
/// final retry = Retry(
///   maxAttempts: 3,
///   delayFactor: const Duration(seconds: 1),
///   retryIf: (error, stackTrace, stats) {
///     // Retry only on network errors
///     return error is NetworkError;
///   },
///   onAttemptFail: (error, stackTrace, stats) {
///     print('Attempt ${stats.attempt} failed: ${error.toString()}');
///   },
/// );
///
/// final result = await retry.execute((stats) => api.getData());
/// ```
class Retry {
  /// Creates a retry instance with specified parameters.
  ///
  /// The retry behavior is determined by the following parameters:
  /// [maxAttempts] - Total number of attempts (including initial)
  /// [delayFactor] - Base duration for delay calculations
  /// [minDelay] - Lower bound for delay duration
  /// [maxDelay] - Upper bound for delay duration
  /// [randomizationFactor] - Adds jitter to delays
  /// [maxTotalTime] - Overall time limit for all attempts (excluding last attempt)
  /// [delayStrategy] - Algorithm for calculating delays
  /// [retryIf] - Custom logic for retry decisions
  /// [onAttempt] - Called before each attempt
  /// [onAttemptFail] - Called after failed attempts
  Retry({
    required int maxAttempts,
    Duration delayFactor = const Duration(milliseconds: 500),
    Duration minDelay = Duration.zero,
    Duration maxDelay = const Duration(seconds: 60),
    double randomizationFactor = 0.25,
    Duration? maxTotalTime,
    this.delayStrategy = DelayStrategy.linear,
    this.retryIf = RetryIf.always,
    this.onAttempt,
    this.onAttemptFail,
  }) : options = RetryOptions(
          maxAttempts: maxAttempts,
          delayFactor: delayFactor,
          minDelay: minDelay,
          maxDelay: maxDelay,
          randomizationFactor: randomizationFactor,
          maxTotalTime: maxTotalTime,
        );

  /// Creates a retry instance from prepared options.
  Retry.byOptions({
    required this.options,
    this.delayStrategy = DelayStrategy.linear,
    this.retryIf = RetryIf.always,
    this.onAttempt,
    this.onAttemptFail,
  });

  /// Creates a retry instance with no retry attempts.
  factory Retry.none() => Retry(
        maxAttempts: 1,
        retryIf: RetryIf.never,
      );

  /// Retry configuration options.
  final RetryOptions options;

  /// Function to determine if a retry attempt should be made.
  final RetryIfFn retryIf;

  /// Strategy for calculating delay between retry attempts.
  final DelayStrategy delayStrategy;

  /// Function called on error, with retry statistics.
  final void Function(Object e, StackTrace s, RetryStats stats)? onAttemptFail;

  /// Function called before each attempt, with retry statistics.
  final void Function(RetryStats stats)? onAttempt;

  final Set<Object?> _activeRetries = {};

  /// Executes a function with retry capability based on the configured retry policy.
  ///
  /// The [function] is executed and, if it throws an exception, will be retried
  /// according to the retry configuration. The function receives the current [RetryStats]
  /// which contains information about the retry state.
  ///
  /// When [key] is provided, the retry operation is identified by this key,
  /// which can be used later to cancel the operation via [cancel].
  ///
  /// Returns the result of the successful function execution.
  FutureOr<R> execute<R>(
    FutureOr<R> Function(RetryStats stats) function, {
    Object? key,
  }) async {
    var attempt = 0;
    final startTime = DateTime.now();
    final stopwatch = Stopwatch()..start();

    Duration? lastDelay;

    _activeRetries.add(key);

    try {
      while (true) {
        attempt++;

        var stats = RetryStats(
          key: key,
          options: options,
          attempt: attempt,
          delayBeforePreviosAttempt: lastDelay,
          delayBeforeNextAttempt: Duration.zero,
          startTime: startTime,
          elapsedTotalTime: stopwatch.elapsed,
          willRetry: null,
          isRetryCanceled: !_activeRetries.contains(key),
        );

        final delay = delayStrategy.calculateDelay(stats);
        lastDelay = delay;

        stats = stats.copyWith(
          delayBeforeNextAttempt: delay,
        );

        try {
          onAttempt?.call(stats);

          final futureOr = function(stats);

          final res = switch (futureOr) {
            Future() => await futureOr,
            _ => futureOr,
          };

          return res;
        } on Object catch (e, s) {
          stats = stats.copyWith(
            elapsedTotalTime: stopwatch.elapsed,
            isRetryCanceled: !_activeRetries.contains(key),
          );

          final retryIfFutureOr = retryIf(e, s, stats);

          final retryIfRes = switch (retryIfFutureOr) {
            Future() => await retryIfFutureOr,
            _ => retryIfFutureOr,
          };

          stats = stats.copyWith(
            elapsedTotalTime: stopwatch.elapsed,
            isRetryCanceled: !_activeRetries.contains(key),
          );

          final willRetry = stats.canRetry && retryIfRes;

          stats = stats.copyWith(
            willRetry: willRetry,
          );

          onAttemptFail?.call(e, s, stats);

          if (!willRetry) {
            rethrow;
          }

          if (delay != Duration.zero) await Future.delayed(delay);
        }
      }
    } finally {
      stopwatch.stop();
      if (key != null) _activeRetries.remove(key);
    }
  }

  /// Cancels a specific retry operation by its key.
  ///
  /// Returns true if the operation was cancelled, false otherwise.
  bool cancel({required Object? key}) {
    return _activeRetries.remove(key);
  }

  /// Cancels all active retry operations.
  ///
  /// Returns true if there were any active operations, false otherwise.
  bool cancellAll() {
    final isNotEmpty = _activeRetries.isNotEmpty;
    _activeRetries.clear();

    return isNotEmpty;
  }
}
