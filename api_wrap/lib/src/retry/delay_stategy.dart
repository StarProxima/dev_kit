import 'dart:math';

import 'retry_options.dart';

final _rand = Random();

/// Function type for delay calculation strategy between retry attempts.
typedef DelayStrategyFn = Duration Function(int attempt, RetryOptions options);

abstract class DelayStrategy {
  /// Exponential delay strategy with jitter (randomization).
  ///
  /// Base formula: minDelay + delayFactor * (2^attempt) * jitter, not exceeding maxDelay.
  static Duration exponential(int attempt, RetryOptions options) {
    final jitter =
        1.0 + options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

    final exp = min(attempt, 31); // Prevent overflow
    final delay = options.minDelay.inMilliseconds +
        options.delayFactor.inMilliseconds * pow(2.0, exp) * jitter;

    final resultMs = delay < options.maxDelay.inMilliseconds
        ? delay
        : options.maxDelay.inMilliseconds;

    return Duration(milliseconds: resultMs.round());
  }

  /// Linear delay strategy with jitter (randomization).
  ///
  /// Base formula: minDelay + delayFactor * attempt * jitter, not exceeding maxDelay.
  static Duration linear(int attempt, RetryOptions options) {
    final jitter =
        1.0 + options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

    final delay = options.minDelay.inMilliseconds +
        options.delayFactor.inMilliseconds * attempt * jitter;

    final resultMs = delay < options.maxDelay.inMilliseconds
        ? delay
        : options.maxDelay.inMilliseconds;

    return Duration(milliseconds: resultMs.round());
  }

  // Random delay stategy.
  //
  // Base formula: minDelay + maxDelay * randromDouble.
  static Duration random(int attempt, RetryOptions options) {
    final delay = options.minDelay.inMilliseconds +
        options.maxDelay.inMilliseconds * _rand.nextDouble();

    return Duration(milliseconds: delay.round());
  }

  /// Fixed delay strategy with jitter (randomization).
  ///
  /// Base formula: delayFactor * jitter.
  static Duration fixed(int attempt, RetryOptions options) {
    final jitter =
        1.0 + options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

    final delay = options.delayFactor.inMilliseconds * jitter;
    return Duration(milliseconds: delay.round());
  }

  /// Constant delay strategy without jitter (randomization).
  ///
  /// Base formula: delayFactor.
  static Duration constant(int attempt, RetryOptions options) {
    final delay = options.delayFactor.inMilliseconds;
    return Duration(milliseconds: delay);
  }

  /// Without delay strategy. Always zero duration.
  static Duration zero(int attempt, RetryOptions options) => Duration.zero;
}
