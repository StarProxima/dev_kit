extension DurationUtilsX on Duration {
  /// Количество полных дней в продолжительности
  int get days => inDays;

  /// Количество полных часов, исключая дни
  int get hours => inHours % Duration.hoursPerDay;

  /// Количество полных минут, исключая часы
  int get minutes => inMinutes % Duration.minutesPerHour;

  /// Количество полных секунд, исключая минуты
  int get seconds => inSeconds % Duration.secondsPerMinute;

  /// Количество полных миллисекунд, исключая секунды
  int get milliseconds => inMilliseconds % Duration.millisecondsPerSecond;

  /// Количество полных микросекунд, исключая миллисекунды
  int get microseconds => inMicroseconds % Duration.microsecondsPerMillisecond;
}
