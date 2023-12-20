extension DateUtilsExtension on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  DateTime get yearAndMonthOnly => DateTime(year, month);

  int get daysInMonth {
    if (month == DateTime.february) {
      final isLeapYear =
          (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
      return isLeapYear ? 29 : 28;
    }
    const daysInMonth = <int>[31, -1, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return daysInMonth[month - 1];
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
}
