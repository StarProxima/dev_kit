import 'dart:math';

import 'retry_options.dart';

final _rand = Random();

/// Function type for delay calculation strategy between retry attempts.
typedef DelayStrategyFn = Duration Function(int attempt, RetryOptions options);

abstract class DelayStrategy {
  /// Exponential delay strategy with jitter.
  ///
  /// Base formula: min + factor * (2^attempt) * jitter, not exceeding max.
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

  /// Linear delay strategy with jitter.
  ///
  /// Base formula: min + factor * attempt * jitter, not exceeding max.
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

  /// Fixed delay strategy with small jitter.
  ///
  /// Base formula: baseDuration * jitter, where baseDuration is taken from delayFactor.
  static Duration fixed(int attempt, RetryOptions options) {
    final jitter =
        1.0 + options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

    final delay = options.delayFactor.inMilliseconds * jitter;
    return Duration(milliseconds: delay.round());
  }
}
