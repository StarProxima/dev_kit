import '../parse_config_exeption.dart';

class DateTimeParser {
  const DateTimeParser();

  DateTime? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value == null) return null;
    if (value is! String) {
      throw ParseConfigException.wrongType(
        rightType: String,
        wrongType: value.runtimeType,
        parserType: DateTimeParser,
        configs: [value],
      );
    }

    final date = DateTime.parse(value);

    return date;
  }
}
