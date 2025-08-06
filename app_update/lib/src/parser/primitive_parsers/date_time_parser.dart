import '../update_config_exception.dart';

class DateTimeParser {
  const DateTimeParser();

  DateTime? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value == null) return null;
    if (value is! String) throw const UpdateConfigException();

    final date = DateTime.parse(value);

    return date;
  }
}
