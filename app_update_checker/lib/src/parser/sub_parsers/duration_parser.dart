part of '../update_config_parser.dart';

class DurationParser {
  UpdateStatusWrapperParser get updateStatusWrapperParser => const UpdateStatusWrapperParser();

  const DurationParser();

  UpdateStatusWrapper<Duration?> parseWithStatuses({
    // ignore: avoid-dynamic
    required dynamic hours,
    required bool isDebug,
  }) {
    // ignore: avoid-inferrable-type-arguments
    return updateStatusWrapperParser.parse<Duration?>(
      hours,
      (value) => parse(hours: value, isDebug: isDebug),
    );
  }

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
