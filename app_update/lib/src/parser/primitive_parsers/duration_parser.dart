import '../common.dart';

class DurationParser {
  const DurationParser();

  Duration? parse({
    // ignore: avoid-dynamic
    required dynamic hours,
  }) {
    if (hours == null) return null;

    if (hours is! int) throw const UpdateConfigException();

    if (hours < 0) {
      throw const UpdateConfigException();
    }

    final duraton = Duration(hours: hours);

    return duraton;
  }
}
