extension DateUtilsX on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  DateTime get yearAndMonthOnly => DateTime(year, month);

  DateTime get mondayOfTheWeek => dateOnly.addDays(-weekday + 1);

  int get daysInMonth {
    if (month == DateTime.february) {
      final isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);

      return isLeapYear ? 29 : 28;
    }
    const daysInMonth = <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    return daysInMonth.elementAtOrNull(month - 1) ?? 30;
  }

  DateTime addMonths(int months) => copyWith(month: month + months);

  DateTime addDays(int days) => copyWith(day: day + days);

  int monthDelta(DateTime other) =>
      (year - other.year) * 12 + (month - other.month);

  int dayDelta(DateTime other) => dateOnly.difference(other.dateOnly).inDays;

  bool isSameMonth(DateTime? other) =>
      year == other?.year && month == other?.month;

  bool isSameDay(DateTime? other) =>
      year == other?.year && month == other?.month && day == other?.day;

  /// Returns week number of current week in a year
  int get weekOfYear {
    int w = _weekNumber;
    final numOfWeeksInCurrentYear = _numOfWeeks(year);
    if (w < 1) {
      w = _numOfWeeks(year - 1);
    } else if (w > numOfWeeksInCurrentYear) {
      w = 1;
    }

    return w;
  }

  /// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
  int get _weekNumber {
    final startDate = DateTime(year);
    final dayOfYear = difference(startDate).inDays + 1;

    return ((dayOfYear - weekday + 10) / 7).floor();
  }

  /// Returns number of weeks in a year
  /// [year] - year to calculate number of weeks
  static int _numOfWeeks(int year) {
    final dec28 = DateTime(year, 12, 28);

    return dec28._weekNumber;
  }
}
