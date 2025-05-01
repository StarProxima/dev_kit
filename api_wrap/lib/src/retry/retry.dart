import 'dart:async';

import '../api_wrap.dart';
import 'delay_stategy.dart';
import 'retry_if.dart';
import 'retry_options.dart';
import 'retry_stats.dart';

/// Класс для управления повторными попытками выполнения функций при ошибках.
class Retry<ErrorType> {
  /// Создает экземпляр ретрая с заданными параметрами.
  ///
  /// Для обратной совместимости параметры указываются напрямую,
  /// они будут преобразованы в RetryOptions.
  Retry({
    required int maxAttempts,
    Duration delayFactor = const Duration(milliseconds: 500),
    Duration minDelay = Duration.zero,
    Duration maxDelay = const Duration(seconds: 10),
    double randomizationFactor = 0.25,
    Duration? maxTotalTime,
    this.delayStrategy = DelayStrategy.exponential,
    this.retryIf = RetryIf.always,
    this.onFail,
  }) : options = RetryOptions(
          maxAttempts: maxAttempts,
          delayFactor: delayFactor,
          minDelay: minDelay,
          maxDelay: maxDelay,
          randomizationFactor: randomizationFactor,
          maxTotalTime: maxTotalTime,
        );

  /// Создает экземпляр ретрая из готовых опций.
  const Retry.byOptions({
    required this.options,
    this.delayStrategy = DelayStrategy.exponential,
    required this.retryIf,
    this.onFail,
  });

  /// Создает экземпляр ретрая без повторных попыток.
  factory Retry.none() {
    return Retry<ErrorType>(
      maxAttempts: 1,
      retryIf: RetryIf.never,
    );
  }

  /// Настройки ретрая.
  final RetryOptions options;

  /// Функция для определения необходимости повторной попытки.
  final RetryIfFn<ErrorType> retryIf;

  /// Стратегия расчета задержки между попытками.
  final DelayStrategyFn delayStrategy;

  /// Функция, вызываемая при ошибке, с указанием статистики попытки.
  final FutureOr<void> Function(ApiError<ErrorType> e, RetryStats stats)?
      onFail;

  /// Выполняет функцию [function] с логикой повторных попыток
  /// в случае возникновения ошибок, согласно настройкам ретрая.
  ///
  /// [function] - функция для выполнения, которая может выбросить исключение.
  /// [wrapError] - функция для обертывания ошибок в [ApiError<ErrorType>].
  ///
  /// Возвращает результат выполнения функции или выбрасывает
  /// последнюю возникшую ошибку, если все попытки не увенчались успехом.
  Future<R> retry<R>(
    Future<R> Function() function, {
    required ApiError<ErrorType> Function(Object error, StackTrace stackTrace)
        wrapError,
  }) async {
    var attempt = 0;
    final startTime = DateTime.now();
    final stopwatch = Stopwatch()..start();
    late ApiError<ErrorType> lastError;

    Duration? remainingTime() {
      if (options.maxTotalTime == null) return null;

      final elapsed = stopwatch.elapsed;
      if (elapsed >= options.maxTotalTime!) return Duration.zero;
      return options.maxTotalTime! - elapsed;
    }

    while (attempt < options.maxAttempts) {
      attempt++;
      try {
        return await function();
      } catch (e, stackTrace) {
        lastError = wrapError(e, stackTrace);

        // Проверяем ограничение по времени
        final remaining = remainingTime();

        // Рассчитываем задержку для следующей попытки
        final delay = delayStrategy(attempt, options);

        // Создаем объект статистики для текущей попытки
        final stats = RetryStats(
          currentAttempt: attempt,
          options: options,
          delayBeforeNextAttempt: delay,
          startTime: startTime,
          elapsed: stopwatch.elapsed,
          remainingTime: remaining,
        );

        // Проверяем, нужно ли повторять попытку
        final canRetry =
            attempt < options.maxAttempts && await retryIf(lastError, stats);
        if (!canRetry) {
          throw lastError;
        }

        // Вызываем обработчик ошибки, если задан
        onFail?.call(lastError, stats);

        if (remaining != null &&
            remaining.inMicroseconds < delay.inMicroseconds) {
          // Если время на ретрай закончилось, выбрасываем последнюю ошибку
          throw lastError;
        }

        await Future.delayed(delay);
      }
    }

    // По идее, мы не достигнем этого никогда, т.к. ошибка выбросится раньше, но на всякий
    throw lastError;
  }
}
