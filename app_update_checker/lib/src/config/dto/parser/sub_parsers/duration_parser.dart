part of '../checker_config_dto_parser.dart';

class _DurationParser {
  final bool isDebug;

  const _DurationParser({required this.isDebug});

  Duration? parse({
    // ignore: avoid-dynamic
    required dynamic hours,
  }) {
    if (hours is! int?) {
      if (isDebug) throw const DtoParserException();
      hours = null;
    } else if (hours != null && hours < 0) {
      throw const DtoParserException();
    }

    final duraton = hours == null ? null : Duration(hours: hours);

    return duraton;
  }
}
