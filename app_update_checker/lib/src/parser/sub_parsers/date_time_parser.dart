part of '../update_config_parser.dart';

class DateTimeParser {
  UpdateStatusWrapperParser get updateStatusWrapperParser => const UpdateStatusWrapperParser();

  const DateTimeParser();

  UpdateStatusWrapper<DateTime?> parseWithStatuses(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    // ignore: avoid-inferrable-type-arguments
    return updateStatusWrapperParser.parse<DateTime?>(
      value,
      (value) => parse(value, isDebug: isDebug),
    );
  }

  DateTime? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is! String) {
      if (value != null && isDebug) throw const UpdateConfigException();

      return null;
    }

    try {
      final dateUtc = DateTime.parse(value);

      return dateUtc;
    } on FormatException catch (e, s) {
      if (isDebug) Error.throwWithStackTrace(const UpdateConfigException(), s);

      return null;
    }
  }
}
