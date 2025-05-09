import 'dart:math';

import 'retry_stats.dart';

final _rand = Random();

/// Function type for delay calculation strategy between retry attempts.
typedef DelayStrategyFn = Duration Function(RetryStats stats);

/// Class providing predefined retry delay calculation strategies.
abstract class DelayStrategy {
  /// Creates a custom delay strategy with the provided calculation function.
  const DelayStrategy();

  /// Calculates the delay before the next retry attempt.
  Duration calculateDelay(RetryStats stats);

  /// {@macro custom_delay_strategy}
  ///
  /// Example:
  /// ```dart
  /// final customStrategy = DelayStrategy.custom((stats) {
  ///   // Custom logic to calculate delay
  ///   return Duration(milliseconds: stats.attempt * 100);
  /// });
  /// ```
  factory DelayStrategy.custom(DelayStrategyFn calculateDelay) =
      CustomDelayStrategy;

  /// {@macro delay_list_strategy}
  ///
  /// Example:
  /// ```dart
  /// final delayStrategy = DelayStrategy.byDelays([
  ///   Duration(seconds: 1),
  ///   Duration(seconds: 2),
  ///   Duration(seconds: 5),
  /// ]);
  /// // first attempt: 1 second
  /// // second attempt: 2 seconds
  /// // third attempt: 5 seconds
  /// // fourth and subsequent attempts: 5 seconds
  /// ```
  factory DelayStrategy.byDelays(List<Duration> delays) = DelayListStrategy;

  /// {@macro exponential_delay_strategy}
  static const DelayStrategy exponential = ExponentialDelayStrategy();

  /// {@macro sqrt_delay_strategy}
  static const DelayStrategy sqrt = SqrtDelayStrategy();

  /// {@macro linear_delay_strategy}
  static const DelayStrategy linear = LinearDelayStrategy();

  /// {@macro random_delay_strategy}
  static const DelayStrategy random = RandomDelayStrategy();

  /// {@macro fixed_delay_strategy}
  static const DelayStrategy fixed = FixedDelayStrategy();

  /// {@macro zero_delay_strategy}
  static const DelayStrategy zero = ZeroDelayStrategy();
}

/// {@template exponential_delay_strategy}
/// Exponential delay strategy with jitter (randomization).
///
/// Base formula: minDelay + delayFactor * (base^attempt) * jitter, not exceeding maxDelay.
///
/// The exponential growth creates increasingly longer delays between retry attempts,
/// which is useful for backing off against rate-limited services or when intermittent
/// failures are expected to resolve with time.
/// {@endtemplate}
class ExponentialDelayStrategy extends DelayStrategy {
  /// Creates an exponential delay strategy.
  ///
  /// [base] is the base for exponential growth (default is 2.0).
  /// Higher values will cause the delay to increase more rapidly with each attempt.
  const ExponentialDelayStrategy({
    this.base = 2.0,
  });

  /// The base for exponential calculation.
  final double base;

  @override
  Duration calculateDelay(RetryStats stats) {
    final jitter =
        1.0 + stats.options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

    final exp = min(stats.attempt, 31); // Prevent overflow
    final delayMs = stats.options.minDelay.inMilliseconds +
        stats.options.delayFactor.inMilliseconds * pow(base, exp) * jitter;

    final resultMs = min(delayMs, stats.options.maxDelay.inMilliseconds);

    return Duration(milliseconds: resultMs.round());
  }
}

/// {@template delay_list_strategy}
/// Delay strategy that uses a predefined list of durations.
///
/// For attempts exceeding the list length, the last duration in the list is used.
/// This allows for complete control over the exact sequence of delays.
/// {@endtemplate}
class DelayListStrategy extends DelayStrategy {
  /// Creates a delay list strategy with the specified delays.
  ///
  /// The [delays] parameter is a list of durations to use for each attempt.
  /// For attempts beyond the list length, the last duration will be used.
  const DelayListStrategy(this.delays);

  /// The list of durations to use for each attempt.
  final List<Duration> delays;

  @override
  Duration calculateDelay(RetryStats stats) {
    assert(delays.isNotEmpty, 'The delay list must not be empty');

    final index = stats.attempt - 1; // attempt is 1-based, list is 0-based
    if (index < delays.length) {
      return delays[index];
    }
    // Return the last duration if attempt exceeds list length
    return delays.last;
  }
}

/// {@template linear_delay_strategy}
/// Linear delay strategy with jitter (randomization).
///
/// Base formula: minDelay + delayFactor * attempt * jitter, not exceeding maxDelay.
///
/// The linear growth provides a more gradual increase in delay between retry attempts,
/// which is useful when you want a predictable backoff that doesn't grow too quickly.
/// {@endtemplate}
class LinearDelayStrategy extends DelayStrategy {
  /// Creates a linear delay strategy.
  ///
  /// {@macro linear_delay_strategy}
  const LinearDelayStrategy();

  @override
  Duration calculateDelay(RetryStats stats) {
    final jitter =
        1.0 + stats.options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

    final delayMs = stats.options.minDelay.inMilliseconds +
        stats.options.delayFactor.inMilliseconds * stats.attempt * jitter;

    final resultMs = min(delayMs, stats.options.maxDelay.inMilliseconds);

    return Duration(milliseconds: resultMs.round());
  }
}

/// {@template random_delay_strategy}
/// Random delay strategy with even distribution.
///
/// Base formula: minDelay + (maxDelay - minDelay) * randomDouble.
///
/// Each delay will be a random value between minDelay and maxDelay, which is useful
/// for avoiding thundering herd problems when multiple clients are retrying simultaneously.
/// {@endtemplate}
class RandomDelayStrategy extends DelayStrategy {
  /// Creates a random delay strategy.
  ///
  /// {@macro random_delay_strategy}
  const RandomDelayStrategy();

  @override
  Duration calculateDelay(RetryStats stats) {
    final delayMs = stats.options.minDelay.inMilliseconds +
        (stats.options.maxDelay.inMilliseconds -
                stats.options.minDelay.inMilliseconds) *
            _rand.nextDouble();

    return Duration(milliseconds: delayMs.round());
  }
}

/// {@template fixed_delay_strategy}
/// Fixed delay strategy with jitter (randomization).
///
/// Base formula: delayFactor * jitter.
///
/// Every retry will have approximately the same delay, which is useful for simple retry scenarios
/// where a consistent delay is desired.
/// {@endtemplate}
class FixedDelayStrategy extends DelayStrategy {
  /// Creates a fixed delay strategy.
  ///
  /// {@macro fixed_delay_strategy}
  const FixedDelayStrategy();

  @override
  Duration calculateDelay(RetryStats stats) {
    final jitter =
        1.0 + stats.options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

    final delayMs = stats.options.delayFactor.inMilliseconds * jitter;
    return Duration(milliseconds: delayMs.round());
  }
}

/// {@template zero_delay_strategy}
/// Zero delay strategy. Always returns zero duration.
///
/// This strategy performs immediate retries without any delay, which is useful when:
/// - You want to implement your own delay logic
/// - You need to retry immediately for time-sensitive operations
/// - You're using the retry mechanism for its condition checking, not for its delay capabilities
/// {@endtemplate}
class ZeroDelayStrategy extends DelayStrategy {
  /// Creates a zero delay strategy.
  ///
  /// {@macro zero_delay_strategy}
  const ZeroDelayStrategy();

  @override
  Duration calculateDelay(RetryStats stats) => Duration.zero;
}

/// {@template sqrt_delay_strategy}
/// Square root delay strategy with jitter (randomization).
///
/// Base formula: minDelay + delayFactor * (attempt^(1/rootDegree)) * jitter, not exceeding maxDelay.
///
/// The square root function creates delays that grow faster than linear but slower than exponential,
/// providing a middle ground between these strategies. This can be useful when exponential growth
/// is too aggressive, but linear growth is too slow.
/// {@endtemplate}
class SqrtDelayStrategy extends DelayStrategy {
  /// Creates a square root delay strategy.
  ///
  /// [rootDegree] is the degree of the root (default is 2.0, meaning square root).
  /// Lower values cause faster growth, higher values cause slower growth.
  const SqrtDelayStrategy({
    this.rootDegree = 2.0,
  });

  /// The degree of the root to apply.
  final double rootDegree;

  @override
  Duration calculateDelay(RetryStats stats) {
    final jitter =
        1.0 + stats.options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

    final rootValue = pow(stats.attempt, 1 / rootDegree);
    final delayMs = stats.options.minDelay.inMilliseconds +
        stats.options.delayFactor.inMilliseconds * rootValue * jitter;

    final resultMs = min(delayMs, stats.options.maxDelay.inMilliseconds);

    return Duration(milliseconds: resultMs.round());
  }
}

/// {@template custom_delay_strategy}
/// Custom delay strategy using a provided calculation function.
///
/// This allows for implementing any custom delay logic, with full access to the retry statistics.
/// Use this when none of the predefined strategies meet your requirements.
/// {@endtemplate}
class CustomDelayStrategy extends DelayStrategy {
  /// Creates a custom delay strategy with the provided calculation function.
  ///
  /// The [calculateDelayFn] parameter is a function that takes [RetryStats] and returns a [Duration].
  /// This function will be called to determine the delay before each retry attempt.
  const CustomDelayStrategy(this._calculateDelayFn);

  /// The function used to calculate the delay.
  final DelayStrategyFn _calculateDelayFn;

  @override
  Duration calculateDelay(RetryStats stats) => _calculateDelayFn(stats);
}
