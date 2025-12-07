import '../parse_config_exeption.dart';

class StringParser {
  const StringParser();

  String? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) {
      throw ParseConfigException.wrongType(
        rightType: String,
        wrongType: value.runtimeType,
        parserType: StringParser,
        configs: [value],
      );
    }

    return value;
  }
}
