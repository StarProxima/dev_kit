import '../update_config_exception.dart';

class DateTimeParser {
  const DateTimeParser();

  DateTime? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value is! String) throw const UpdateConfigException();

    try {
      final date = DateTime.parse(value);

      return date;
    } on FormatException catch (e, s) {
      Error.throwWithStackTrace(const UpdateConfigException(), s);
    }
  }
}
