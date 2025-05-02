import 'dart:async';

import '../api_wrap.dart';
import 'delay_stategy.dart';
import 'retry_if.dart';
import 'retry_options.dart';
import 'retry_stats.dart';

/// Class for managing retry attempts when functions encounter errors.
class Retry<ErrorType> {
  /// Creates a retry instance with specified parameters.
  Retry({
    required int maxAttempts,
    Duration delayFactor = const Duration(milliseconds: 500),
    Duration minDelay = Duration.zero,
    Duration maxDelay = const Duration(seconds: 10),
    double randomizationFactor = 0.25,
    Duration? maxTotalTime,
    this.delayStrategy = DelayStrategy.exponential,
    this.retryIf = RetryIf.always,
    this.onAttempt,
    this.onFailAttempt,
  }) : options = RetryOptions(
          maxAttempts: maxAttempts,
          delayFactor: delayFactor,
          minDelay: minDelay,
          maxDelay: maxDelay,
          randomizationFactor: randomizationFactor,
          maxTotalTime: maxTotalTime,
        );

  /// Creates a retry instance from prepared options.
  const Retry.byOptions({
    required this.options,
    this.delayStrategy = DelayStrategy.exponential,
    this.retryIf = RetryIf.always,
    this.onAttempt,
    this.onFailAttempt,
  });

  /// Creates a retry instance with no retry attempts.
  factory Retry.none() => Retry<ErrorType>(
        maxAttempts: 1,
        retryIf: RetryIf.never,
      );

  /// Retry configuration options.
  final RetryOptions options;

  /// Function to determine if a retry attempt should be made.
  final RetryIfFn<ErrorType> retryIf;

  /// Strategy for calculating delay between retry attempts.
  final DelayStrategyFn delayStrategy;

  /// Function called on error, with retry statistics.
  final FutureOr<void> Function(ApiError<ErrorType> e, RetryStats stats)?
      onFailAttempt;

  /// Function called before each attempt, with retry statistics.
  final FutureOr<void> Function(RetryStats stats)? onAttempt;

  /// Executes the [function] with retry logic in case of errors,
  /// according to the retry settings.
  ///
  /// [function] - function to execute that may throw an exception.
  /// [wrapError] - function to wrap errors in [ApiError<ErrorType>].
  ///
  /// Returns the result of the function or throws the last error
  /// if all attempts were unsuccessful.
  Future<R> retry<R>(
    Future<R> Function() function, {
    required ApiError<ErrorType> Function(Object error, StackTrace stackTrace)
        wrapError,
  }) async {
    var attempt = 0;
    final startTime = DateTime.now();
    final stopwatch = Stopwatch()..start();

    late ApiError<ErrorType> lastError;
    Duration? lastDelay;

    while (true) {
      attempt++;

      // Calculate delay for the next attempt
      final delay = delayStrategy(attempt, options);

      final stats = RetryStats(
        options: options,
        attempt: attempt,
        delayBeforePreviosAttempt: lastDelay,
        delayBeforeNextAttempt: delay,
        startTime: startTime,
        elapsedTime: stopwatch.elapsed,
      );

      try {
        onAttempt?.call(stats);
        return await function();
      } catch (e, stackTrace) {
        lastError = wrapError(e, stackTrace);

        lastDelay = delay;

        final willRetry = stats.canRetry && await retryIf(lastError, stats);

        onFailAttempt?.call(lastError, stats.copyWith(willRetry: willRetry));

        if (!willRetry) throw lastError;

        await Future.delayed(delay);
      }
    }
  }
}
