import '../parse_config_exeption.dart';

class CustomParamsParser {
  const CustomParamsParser();

  Map<String, dynamic>? parse(
    Object? value,
  ) {
    if (value == null) return null;

    if (value is! Map<String, dynamic>) {
      throw ParseConfigException.wrongType(
        rightType: Map<String, dynamic>,
        wrongType: value.runtimeType,
        parserType: CustomParamsParser,
        configs: [value],
      );
    }

    return value;
  }
}
