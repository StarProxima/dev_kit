import 'dart:math';

import 'retry_stats.dart';

final _rand = Random();

/// Function type for delay calculation strategy between retry attempts.
typedef DelayStrategyFn = Duration Function(RetryStats stats);

abstract class DelayStrategy {
  /// Exponential delay strategy with jitter (randomization).
  ///
  /// Base formula: minDelay + delayFactor * (2^attempt) * jitter, not exceeding maxDelay.
  static Duration exponential(RetryStats stats) {
    final jitter =
        1.0 + stats.options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

    final exp = min(stats.attempt, 31); // Prevent overflow
    final delayMs = stats.options.minDelay.inMilliseconds +
        stats.options.delayFactor.inMilliseconds * pow(2.0, exp) * jitter;

    final resultMs = min(delayMs, stats.options.maxDelay.inMilliseconds);

    return Duration(milliseconds: resultMs.round());
  }

  /// Linear delay strategy with jitter (randomization).
  ///
  /// Base formula: minDelay + delayFactor * attempt * jitter, not exceeding maxDelay.
  static Duration linear(RetryStats stats) {
    final jitter =
        1.0 + stats.options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

    final delayMs = stats.options.minDelay.inMilliseconds +
        stats.options.delayFactor.inMilliseconds * stats.attempt * jitter;

    final resultMs = min(delayMs, stats.options.maxDelay.inMilliseconds);

    return Duration(milliseconds: resultMs.round());
  }

  // Random delay stategy.
  //
  // Base formula: minDelay + maxDelay * randromDouble.
  static Duration random(RetryStats stats) {
    final delayMs = stats.options.minDelay.inMilliseconds +
        (stats.options.maxDelay.inMilliseconds -
                stats.options.minDelay.inMilliseconds) *
            _rand.nextDouble();

    return Duration(milliseconds: delayMs.round());
  }

  /// Fixed delay strategy with jitter (randomization).
  ///
  /// Base formula: delayFactor * jitter.
  static Duration fixed(RetryStats stats) {
    final jitter =
        1.0 + stats.options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

    final delayMs = stats.options.delayFactor.inMilliseconds * jitter;
    return Duration(milliseconds: delayMs.round());
  }

  /// Without delay strategy. Always zero duration.
  static Duration zero(RetryStats stats) => Duration.zero;
}
