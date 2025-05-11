import 'retry_options.dart';

/// Class containing statistics and information about the current state of the retry process.
class RetryStats {
  /// Creates an instance of retry statistics.
  RetryStats({
    required this.key,
    required this.options,
    required this.currentAttempt,
    required this.failedAttempts,
    required this.delayBeforePreviosAttempt,
    required this.delayBeforeNextAttempt,
    required this.startTime,
    required this.elapsedTotalTime,
    required bool? willRetry,
    required this.isRetryCanceled,
  }) : _willRetry = willRetry;

  // Retry operation identifier.
  final Object? key;

  /// Retry configuration options.
  final RetryOptions options;

  /// Current attempt (starting from 1).
  final int currentAttempt;

  /// Number of failed attempts.
  final int failedAttempts;

  /// Delay before the current attempt.
  final Duration? delayBeforePreviosAttempt;

  /// Delay before the next attempt.
  final Duration delayBeforeNextAttempt;

  /// Start time of the retry process.
  final DateTime startTime;

  /// Elapsed time since the beginning of execution.
  final Duration elapsedTotalTime;

  /// Whether retry was stopped externally.
  final bool isRetryCanceled;

  /// Whether another attempt is possible.
  bool get canRetry =>
      hasTotalTimeForNextAttempt && hasAttempts && !isRetryCanceled;

  final bool? _willRetry;

  /// Whether another attempt will be made.
  bool get willRetry => _willRetry ?? canRetry;

  /// Remaining time until reaching maxTotalTime, if specified.
  /// Null if maxTotalTime is not set.
  Duration? get remainingTotalTime {
    final maxTotalTime = options.maxTotalTime;
    if (maxTotalTime == null) return null;

    if (elapsedTotalTime >= maxTotalTime) return Duration.zero;
    return maxTotalTime - elapsedTotalTime;
  }

  /// Whether there is enough time left for another attempt based on maxTotalTime.
  /// Returns true if either no time limit is set, or there is sufficient time
  /// for the next delay.
  bool get hasTotalTimeForNextAttempt =>
      remainingTotalTime == null ||
      remainingTotalTime!.inMicroseconds >
          delayBeforeNextAttempt.inMicroseconds;

  /// Number of remaining attempts.
  int get attemptsLeft => options.maxAttempts - currentAttempt;

  /// Is first attempt
  bool get isFirstAttempt => currentAttempt == 1;

  /// Whether there are remaining attempts.
  bool get hasAttempts => attemptsLeft > 0;

  /// Creates a copy of the object with optional field overrides.
  RetryStats copyWith({
    Object? key,
    RetryOptions? options,
    int? currentAttempt,
    int? failedAttempts,
    Duration? delayBeforePreviosAttempt,
    Duration? delayBeforeNextAttempt,
    DateTime? startTime,
    Duration? elapsedTotalTime,
    bool? willRetry,
    bool? isRetryCanceled,
  }) {
    return RetryStats(
      key: key ?? this.key,
      options: options ?? this.options,
      currentAttempt: currentAttempt ?? this.currentAttempt,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      delayBeforePreviosAttempt:
          delayBeforePreviosAttempt ?? this.delayBeforePreviosAttempt,
      delayBeforeNextAttempt:
          delayBeforeNextAttempt ?? this.delayBeforeNextAttempt,
      startTime: startTime ?? this.startTime,
      elapsedTotalTime: elapsedTotalTime ?? this.elapsedTotalTime,
      willRetry: willRetry ?? _willRetry,
      isRetryCanceled: isRetryCanceled ?? this.isRetryCanceled,
    );
  }

  @override
  String toString() =>
      'RetryStats(key: $key, currentAttempt: $currentAttempt, failedAttempts: $failedAttempts, delayBeforeNextAttempt: $delayBeforeNextAttempt, elapsedTotalTime: $elapsedTotalTime, willRetry: $willRetry)';

  @override
  int get hashCode => Object.hash(
        key,
        options,
        currentAttempt,
        failedAttempts,
        delayBeforeNextAttempt,
        elapsedTotalTime,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RetryStats) return false;
    return key == other.key &&
        options == other.options &&
        currentAttempt == other.currentAttempt &&
        failedAttempts == other.failedAttempts &&
        delayBeforeNextAttempt == other.delayBeforeNextAttempt &&
        elapsedTotalTime == other.elapsedTotalTime &&
        willRetry == other.willRetry &&
        isRetryCanceled == other.isRetryCanceled;
  }
}
