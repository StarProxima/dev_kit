import 'dart:math';

import 'retry_options.dart';

final _rand = Random();

/// Функциональный тип для стратегии расчета задержки между попытками.
typedef DelayStrategyFn = Duration Function(int attempt, RetryOptions options);

abstract class DelayStrategy {
  /// Экспоненциальная стратегия задержки с джиттером.
  ///
  /// Базовая формула: min + factor * (2^attempt) * jitter, не превышая max.
  static Duration exponential(int attempt, RetryOptions options) {
    final jitter =
        1.0 + options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

    final exp = min(attempt, 31); // Предотвращаем переполнение
    final delay = options.minDelay.inMilliseconds +
        options.delayFactor.inMilliseconds * pow(2.0, exp) * jitter;

    final resultMs = delay < options.maxDelay.inMilliseconds
        ? delay
        : options.maxDelay.inMilliseconds;

    return Duration(milliseconds: resultMs.round());
  }

  /// Линейная стратегия задержки с джиттером.
  ///
  /// Базовая формула: min + factor * attempt * jitter, не превышая max.
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

  /// Стратегия с фиксированной задержкой и небольшим джиттером.
  ///
  /// Базовая формула: baseDuration * jitter, где baseDuration берется из delayFactor.
  static Duration fixed(int attempt, RetryOptions options) {
    final jitter = 1.0 +
        options.randomizationFactor *
            (_rand.nextDouble() * 2 - 1) /
            2; // Меньший джиттер для фиксированной задержки

    final delay = options.delayFactor.inMilliseconds * jitter;
    return Duration(milliseconds: delay.round());
  }
}
