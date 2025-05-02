/// Настройки ретрая, используемые для расчета задержек и условий повторных попыток.
class RetryOptions {
  const RetryOptions({
    required this.maxAttempts,
    this.delayFactor = const Duration(milliseconds: 500),
    this.minDelay = Duration.zero,
    this.maxDelay = const Duration(seconds: 10),
    this.randomizationFactor = 0.25,
    this.maxTotalTime,
  }) : assert(maxAttempts > 0, 'maxAttempts must be greater than 0');

  /// Максимальное количество попыток.
  final int maxAttempts;

  /// Базовый коэффициент задержки между попытками.
  final Duration delayFactor;

  /// Минимальная задержка между попытками.
  final Duration minDelay;

  /// Максимальная задержка между попытками.
  final Duration maxDelay;

  /// Фактор случайности для джиттера.
  final double randomizationFactor;

  /// Максимальное общее время выполнения всех попыток.
  /// Если null, ограничение по времени не применяется.
  final Duration? maxTotalTime;

  /// Создает копию опций с новыми значениями.
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
