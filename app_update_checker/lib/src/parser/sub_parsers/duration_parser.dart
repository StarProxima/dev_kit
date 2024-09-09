part of '../update_config_parser.dart';

class DurationParser {
  const DurationParser();

  Duration? parse({
    // ignore: avoid-dynamic
    required dynamic hours,
    required bool isDebug,
  }) {
    if (hours is! int?) {
      if (isDebug) throw const UpdateConfigException();
      hours = null;
    } else if (hours != null && hours < 0) {
      throw const UpdateConfigException();
    }

    final duraton = hours == null ? null : Duration(hours: hours);

    return duraton;
  }
}
