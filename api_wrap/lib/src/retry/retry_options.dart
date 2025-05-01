/// Настройки ретрая, используемые для расчета задержек и условий повторных попыток.
class RetryOptions {
  const RetryOptions({
    required this.maxAttempts,
    this.delayFactor = const Duration(milliseconds: 500),
    this.minDelay = Duration.zero,
    this.maxDelay = const Duration(seconds: 10),
    this.randomizationFactor = 0.25,
    this.maxTotalTime,
    this.stopOnTotalTimeLimit = true,
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
  final Duration? maxTotalTime;

  /// Если true, прекращает повторные попытки, когда времени не осталось.
  /// Если false, всегда делает хотя бы одну попытку, даже если времени уже нет.
  final bool stopOnTotalTimeLimit;

  /// Создает копию опций с новыми значениями.
  RetryOptions copyWith({
    int? maxAttempts,
    Duration? delayFactor,
    Duration? minDelay,
    Duration? maxDelay,
    double? randomizationFactor,
    Duration? maxTotalTime,
    bool? stopOnTotalTimeLimit,
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
