import 'retry_options.dart';

/// Класс, содержащий статистику и информацию о текущем состоянии процесса повторных попыток.
class RetryStats {
  /// Создает экземпляр статистики повторных попыток.
  RetryStats({
    required this.currentAttempt,
    required this.options,
    required this.delayBeforeNextAttempt,
    required this.startTime,
    required this.elapsed,
    required this.remainingTime,
  });

  /// Текущая попытка (начиная с 1).
  final int currentAttempt;

  /// Настройки ретрая.
  final RetryOptions options;

  /// Задержка перед следующей попыткой.
  final Duration delayBeforeNextAttempt;

  /// Время начала выполнения ретрая.
  final DateTime startTime;

  /// Прошедшее время с начала выполнения.
  final Duration elapsed;

  /// Оставшееся время до достижения maxTotalTime, если оно задано.
  /// Null, если maxTotalTime не задан.
  final Duration? remainingTime;

  /// Количество оставшихся попыток.
  int get attemptsLeft => options.maxAttempts - currentAttempt;

  /// Общее количество возможных попыток.
  int get totalAttempts => options.maxAttempts;

  /// Процент выполненных попыток.
  double get attemptProgress => currentAttempt / totalAttempts;

  /// Процент истекшего времени от maxTotalTime.
  /// Null, если maxTotalTime не задан.
  double? get timeProgress => options.maxTotalTime != null
      ? elapsed.inMilliseconds / options.maxTotalTime!.inMilliseconds
      : null;

  /// Будет ли выполнена еще одна попытка.
  bool get willRetry => currentAttempt < options.maxAttempts;
}
