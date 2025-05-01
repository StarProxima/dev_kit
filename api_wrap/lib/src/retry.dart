part of 'api_wrap.dart';

final _rand = math.Random();

bool _alwaysRetryIf(ApiError e) => true;

bool _connectionRetryIf(ApiError e) {
  if (e is! InternalError) return false;
  final error = e.error;
  return switch (error) {
    DioException(type: DioExceptionType.badResponse) => false,
    DioException(requestOptions: RequestOptions(method: 'GET')) => true,
    SocketException() || TimeoutException() => true,
    _ => false,
  };
}

typedef RetryIf<ErrorType> = FutureOr<bool> Function(ApiError<ErrorType> e);

/// Функциональный тип для стратегии расчета задержки между попытками.
typedef DelayStrategy = Duration Function(int attempt, RetryOptions options);

/// Экспоненциальная стратегия задержки с джиттером.
///
/// Базовая формула: min + factor * (2^attempt) * jitter, не превышая max.
Duration exponentialBackoff(int attempt, RetryOptions options) {
  final jitter =
      1.0 + options.randomizationFactor * (_rand.nextDouble() * 2 - 1);

  final exp = math.min(attempt, 31); // Предотвращаем переполнение
  final delay = options.minDelay.inMilliseconds +
      options.delayFactor.inMilliseconds * math.pow(2.0, exp) * jitter;

  final resultMs = delay < options.maxDelay.inMilliseconds
      ? delay
      : options.maxDelay.inMilliseconds;

  return Duration(milliseconds: resultMs.round());
}

/// Линейная стратегия задержки с джиттером.
///
/// Базовая формула: min + factor * attempt * jitter, не превышая max.
Duration linearDelay(int attempt, RetryOptions options) {
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
Duration fixedDelay(int attempt, RetryOptions options) {
  final jitter = 1.0 +
      options.randomizationFactor *
          (_rand.nextDouble() * 2 - 1) /
          2; // Меньший джиттер для фиксированной задержки

  final delay = options.delayFactor.inMilliseconds * jitter;
  return Duration(milliseconds: delay.round());
}

/// Настройки ретрая, используемые для расчета задержек и условий повторных попыток.
class RetryOptions {
  const RetryOptions({
    required this.maxAttempts,
    this.delayFactor = const Duration(milliseconds: 500),
    this.minDelay = Duration.zero,
    this.maxDelay = const Duration(seconds: 10),
    this.randomizationFactor = 0.25,
    this.maxTotalDuration,
    this.stopOnNoDurationLeft = true,
  })  : assert(maxAttempts > 0, 'maxAttempts must be greater than 0'),
        assert(randomizationFactor >= 0 && randomizationFactor <= 1,
            'randomizationFactor must be between 0 and 1');

  /// Максимальное количество попыток.
  final int maxAttempts;

  /// Базовый коэффициент задержки между попытками.
  final Duration delayFactor;

  /// Минимальная задержка между попытками.
  final Duration minDelay;

  /// Максимальная задержка между попытками.
  final Duration maxDelay;

  /// Фактор случайности для джиттера (от 0 до 1).
  final double randomizationFactor;

  /// Максимальное общее время выполнения всех попыток.
  /// Если null, ограничение по времени не применяется.
  final Duration? maxTotalDuration;

  /// Если true, прекращает повторные попытки, когда времени не осталось.
  /// Если false, всегда делает хотя бы одну попытку, даже если времени уже нет.
  final bool stopOnNoDurationLeft;

  /// Создает копию опций с новыми значениями.
  RetryOptions copyWith({
    int? maxAttempts,
    Duration? delayFactor,
    Duration? minDelay,
    Duration? maxDelay,
    double? randomizationFactor,
    Duration? maxTotalDuration,
    bool? stopOnNoDurationLeft,
  }) {
    return RetryOptions(
      maxAttempts: maxAttempts ?? this.maxAttempts,
      delayFactor: delayFactor ?? this.delayFactor,
      minDelay: minDelay ?? this.minDelay,
      maxDelay: maxDelay ?? this.maxDelay,
      randomizationFactor: randomizationFactor ?? this.randomizationFactor,
      maxTotalDuration: maxTotalDuration ?? this.maxTotalDuration,
      stopOnNoDurationLeft: stopOnNoDurationLeft ?? this.stopOnNoDurationLeft,
    );
  }
}

/// Класс для управления повторными попытками выполнения функций при ошибках.
class Retry<ErrorType> {
  /// Создает экземпляр ретрая с заданными параметрами.
  ///
  /// Для обратной совместимости параметры указываются напрямую,
  /// они будут преобразованы в RetryOptions.
  Retry({
    int maxAttempts = 3,
    Duration delayFactor = const Duration(milliseconds: 500),
    Duration minDelay = Duration.zero,
    Duration maxDelay = const Duration(seconds: 10),
    double randomizationFactor = 0.25,
    Duration? maxTotalDuration,
    this.retryIf = _alwaysRetryIf,
    this.onError,
    DelayStrategy? delayStrategy,
  })  : options = RetryOptions(
          maxAttempts: maxAttempts,
          delayFactor: delayFactor,
          minDelay: minDelay,
          maxDelay: maxDelay,
          randomizationFactor: randomizationFactor,
          maxTotalDuration: maxTotalDuration,
        ),
        delayStrategy = delayStrategy ?? exponentialBackoff;

  /// Создает экземпляр ретрая из готовых опций.
  const Retry.byOptions({
    required this.options,
    required this.retryIf,
    required this.delayStrategy,
    this.onError,
  });

  /// Создает экземпляр ретрая без повторных попыток.
  factory Retry.no() {
    return Retry<ErrorType>(
      maxAttempts: 1,
      retryIf: (_) => false,
    );
  }

  /// Настройки ретрая.
  final RetryOptions options;

  /// Функция для определения необходимости повторной попытки.
  final RetryIf<ErrorType> retryIf;

  /// Стратегия расчета задержки между попытками.
  final DelayStrategy delayStrategy;

  /// Функция, вызываемая при ошибке, с указанием задержки до следующей попытки.
  final FutureOr<void> Function(
    ApiError<ErrorType> e,
    Duration delayBeforeNextAttemt,
  )? onError;

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
    final stopwatch = Stopwatch()..start();
    ApiError<ErrorType>? lastError;

    Duration? remainingTime() {
      if (options.maxTotalDuration == null) return null;

      final elapsed = stopwatch.elapsed;
      if (elapsed >= options.maxTotalDuration!) return Duration.zero;
      return options.maxTotalDuration! - elapsed;
    }

    while (attempt < options.maxAttempts) {
      // Проверяем ограничение по времени
      final remaining = remainingTime();
      if (remaining != null &&
          remaining.inMicroseconds <= 0 &&
          options.stopOnNoDurationLeft) {
        // Если время вышло и есть предыдущая ошибка, используем её
        if (lastError != null) {
          throw lastError;
        }
        // Иначе пробуем выполнить функцию хотя бы раз
      }

      attempt++;
      try {
        return await function();
      } catch (e, stackTrace) {
        lastError = wrapError(e, stackTrace);

        // Проверяем, нужно ли повторять попытку
        final canRetry =
            attempt < options.maxAttempts && await retryIf(lastError);
        if (!canRetry) {
          throw lastError;
        }

        // Проверяем, останется ли время после задержки
        final delay = delayStrategy(attempt, options);
        if (remaining != null &&
            remaining.inMicroseconds < delay.inMicroseconds &&
            options.stopOnNoDurationLeft) {
          // Если время на ретрай закончилось, выбрасываем последнюю ошибку
          throw lastError;
        }

        onError?.call(lastError, delay);
        await Future.delayed(delay);
      }
    }

    // Если дошли до этого места, значит все попытки исчерпаны
    // и у нас должна быть последняя ошибка
    throw lastError!;
  }
}
