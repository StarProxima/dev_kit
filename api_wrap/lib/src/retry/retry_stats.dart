import 'retry_options.dart';

/// Класс, содержащий статистику и информацию о текущем состоянии процесса повторных попыток.
class RetryStats {
  /// Создает экземпляр статистики повторных попыток.
  RetryStats({
    required this.options,
    required this.attempt,
    required this.delay,
    required this.startTime,
    required this.elapsedTime,
    bool? willRetry,
  }) : _willRetry = willRetry;

  /// Настройки ретрая.
  final RetryOptions options;

  /// Текущая попытка (начиная с 1).
  final int attempt;

  /// Задержка перед следующей попыткой.
  final Duration delay;

  /// Время начала выполнения ретрая.
  final DateTime startTime;

  /// Прошедшее время с начала выполнения.
  final Duration elapsedTime;

  final bool? _willRetry;

  /// Будет ли выполнена еще одна попытка.
  bool? get willRetry => _willRetry ?? canRetry;

  /// Оставшееся время до достижения maxTotalTime, если оно задано.
  /// Null, если maxTotalTime не задан.
  Duration? get remainingTime => _calculateRemainingTime();

  bool get hasTime =>
      remainingTime == null ||
      remainingTime!.inMicroseconds > delay.inMicroseconds;

  /// Количество оставшихся попыток.
  int get attemptsLeft => options.maxAttempts - attempt;

  // Есть ли оставшиеся попытки.
  bool get hasAttempts => attemptsLeft <= 0;

  /// Возможна ли еще одна попытка.
  bool get canRetry => hasTime && hasAttempts;

  Duration? _calculateRemainingTime() {
    if (options.maxTotalTime == null) return null;

    if (elapsedTime >= options.maxTotalTime!) return Duration.zero;
    return options.maxTotalTime! - elapsedTime;
  }

  /// Создает копию объекта с возможностью переопределения полей.
  RetryStats copyWith({
    RetryOptions? options,
    int? attempt,
    Duration? delay,
    DateTime? startTime,
    Duration? elapsedTime,
    bool? willRetry,
  }) {
    return RetryStats(
      options: options ?? this.options,
      attempt: attempt ?? this.attempt,
      delay: delay ?? this.delay,
      startTime: startTime ?? this.startTime,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      willRetry: willRetry ?? _willRetry,
    );
  }
}
