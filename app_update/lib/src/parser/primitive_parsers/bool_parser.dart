import '../parse_config_exeption.dart';

class BoolParser {
  const BoolParser();

  // ignore: prefer-boolean-prefixes
  bool? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! bool) {
      throw ParseConfigException.wrongType(
        rightType: bool,
        wrongType: value.runtimeType,
        parserType: BoolParser,
        configs: [value],
      );
    }

    return value;
  }
}
