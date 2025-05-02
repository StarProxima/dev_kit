/// Retry configuration options used for calculating delays and retry conditions.
class RetryOptions {
  const RetryOptions({
    required this.maxAttempts,
    this.delayFactor = const Duration(milliseconds: 500),
    this.minDelay = Duration.zero,
    this.maxDelay = const Duration(seconds: 10),
    this.randomizationFactor = 0.25,
    this.maxTotalTime,
  }) : assert(maxAttempts > 0, 'maxAttempts must be greater than 0');

  /// Maximum number of retry attempts.
  final int maxAttempts;

  /// Base delay factor between retry attempts.
  final Duration delayFactor;

  /// Minimum delay between retry attempts.
  final Duration minDelay;

  /// Maximum delay between retry attempts.
  final Duration maxDelay;

  /// Randomization factor for jitter.
  final double randomizationFactor;

  /// Maximum total execution time for all retry attempts.
  /// If null, no time limit is applied.
  final Duration? maxTotalTime;

  /// Creates a copy of the options with new values.
  RetryOptions copyWith({
    int? maxAttempts,
    Duration? delayFactor,
    Duration? minDelay,
    Duration? maxDelay,
    double? randomizationFactor,
    Duration? maxTotalTime,
  }) {
    return RetryOptions(
      maxAttempts: maxAttempts ?? this.maxAttempts,
      delayFactor: delayFactor ?? this.delayFactor,
      minDelay: minDelay ?? this.minDelay,
      maxDelay: maxDelay ?? this.maxDelay,
      randomizationFactor: randomizationFactor ?? this.randomizationFactor,
      maxTotalTime: maxTotalTime ?? this.maxTotalTime,
    );
  }
}
