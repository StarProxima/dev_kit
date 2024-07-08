/// Provides additional time utility getters for the Duration class.
///
/// ```
/// Duration duration = Duration(days: 1, hours: 5, minutes: 30, seconds: 45);
///
/// print(duration.days);         // 1
/// print(duration.hours);        // 5
/// print(duration.minutes);      // 30
/// print(duration.seconds);      // 45
/// print(duration.milliseconds); // 0
/// ```
extension DurationUtilsX on Duration {
  // Total number of days.
  int get days => inDays;

  // Number of hours that are not part of a full day.
  int get hours => inHours % Duration.hoursPerDay;

  // Number of minutes that are not part of a full hour.
  int get minutes => inMinutes % Duration.minutesPerHour;

  // Number of seconds that are not part of a full minute.
  int get seconds => inSeconds % Duration.secondsPerMinute;

  // Number of milliseconds that are not part of a full second.
  int get milliseconds => inMilliseconds % Duration.millisecondsPerSecond;

  // Number of microseconds that are not part of a full millisecond.
  int get microseconds => inMicroseconds % Duration.microsecondsPerMillisecond;
}

/// Adds extensions to num (ie. int & double) to make creating durations simple:
///
/// ```
/// 200.ms // equivalent to Duration(milliseconds: 200)
/// 3.5.seconds // equivalent to Duration(milliseconds: 3500)
/// 1.5.days // equivalent to Duration(hours: 36)
/// ```
extension DurationFromNumX on num {
  Duration get days => Duration(milliseconds: (this * 86400000).toInt());
  Duration get hours => Duration(milliseconds: (this * 3600000).toInt());
  Duration get min => Duration(milliseconds: (this * 60000).toInt());
  Duration get sec => Duration(milliseconds: (this * 1000).toInt());
  Duration get ms => Duration(milliseconds: toInt());
}
