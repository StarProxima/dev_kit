import '../models/update_config_exception.dart';

class DateTimeParser {
  const DateTimeParser();

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
