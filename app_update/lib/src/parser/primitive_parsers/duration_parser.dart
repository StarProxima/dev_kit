import '../parse_config_exeption.dart';

class DurationParser {
  const DurationParser();

  Duration? parse({
    // ignore: avoid-dynamic
    required dynamic hours,
  }) {
    if (hours == null) return null;

    if (hours is! int) {
      throw ParseConfigException.wrongType(
        rightType: int,
        wrongType: hours.runtimeType,
        parserType: DurationParser,
        configs: [hours],
      );
    }

    if (hours < 0) {
      throw const ParseConfigException();
    }

    final duraton = Duration(hours: hours);

    return duraton;
  }
}
