import '../../shared/update_status_wrapper.dart';
import '../models/update_config_exception.dart';
import '../update_config_parser.dart';

class DurationParser {
  UpdateStatusWrapperParser get updateStatusWrapperParser => const UpdateStatusWrapperParser();

  const DurationParser();

  UpdateStatusWrapper<Duration?> parseWithStatuses({
    // ignore: avoid-dynamic
    required dynamic hours,
    required bool isDebug,
    required WrapperMode mode,
  }) {
    // ignore: avoid-inferrable-type-arguments
    return updateStatusWrapperParser.parse<Duration?>(
      hours,
      parse: (value) => parse(hours: value, isDebug: isDebug),
      mode: mode,
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
