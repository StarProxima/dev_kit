import 'retry_options.dart';

/// Class containing statistics and information about the current state of the retry process.
class RetryStats {
  /// Creates an instance of retry statistics.
  RetryStats({
    required this.key,
    required this.options,
    required this.attempt,
    required this.delayBeforePreviosAttempt,
    required this.delayBeforeNextAttempt,
    required this.startTime,
    required this.elapsedTime,
    required bool? willRetry,
    required this.retryIsCancaled,
  }) : _willRetry = willRetry;

  final Object? key;

  /// Retry configuration options.
  final RetryOptions options;

  /// Current attempt (starting from 1).
  final int attempt;

  /// Delay before the current attempt.
  final Duration? delayBeforePreviosAttempt;

  /// Delay before the next attempt.
  final Duration delayBeforeNextAttempt;

  /// Start time of the retry process.
  final DateTime startTime;

  /// Elapsed time since the beginning of execution.
  final Duration elapsedTime;

  final bool? _willRetry;

  final bool retryIsCancaled;

  /// Whether another attempt is possible.
  bool get canRetry => hasTime && hasAttempts && !retryIsCancaled;

  /// Whether another attempt will be made.
  bool? get willRetry => _willRetry ?? canRetry;

  /// Remaining time until reaching maxTotalTime, if specified.
  /// Null if maxTotalTime is not set.
  Duration? get remainingTime {
    if (options.maxTotalTime == null) return null;

    if (elapsedTime >= options.maxTotalTime!) return Duration.zero;
    return options.maxTotalTime! - elapsedTime;
  }

  /// Whether there is enough time left for another attempt based on maxTotalTime.
  /// Returns true if either no time limit is set, or there is sufficient time
  /// for the next delay.
  bool get hasTime =>
      remainingTime == null ||
      remainingTime!.inMicroseconds > delayBeforeNextAttempt.inMicroseconds;

  /// Number of remaining attempts.
  int get attemptsLeft => options.maxAttempts - attempt;

  /// Is first attempt
  bool get isFirstAttempt => attempt == 1;

  /// Whether there are remaining attempts.
  bool get hasAttempts => attemptsLeft > 0;

  /// Creates a copy of the object with optional field overrides.
  RetryStats copyWith({
    Object? key,
    RetryOptions? options,
    int? attempt,
    Duration? delayBeforePreviosAttempt,
    Duration? delayBeforeNextAttempt,
    DateTime? startTime,
    Duration? elapsedTime,
    bool? willRetry,
    bool? retryIsCancaled,
  }) {
    return RetryStats(
      key: key ?? this.key,
      options: options ?? this.options,
      attempt: attempt ?? this.attempt,
      delayBeforePreviosAttempt:
          delayBeforePreviosAttempt ?? this.delayBeforePreviosAttempt,
      delayBeforeNextAttempt:
          delayBeforeNextAttempt ?? this.delayBeforeNextAttempt,
      startTime: startTime ?? this.startTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      willRetry: willRetry ?? _willRetry,
      retryIsCancaled: retryIsCancaled ?? this.retryIsCancaled,
    );
  }
}
