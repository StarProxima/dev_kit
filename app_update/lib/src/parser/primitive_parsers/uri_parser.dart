import '../parse_config_exeption.dart';

class UriParser {
  const UriParser();

  // ignore: prefer-boolean-prefixes
  Uri? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) {
      throw ParseConfigException.wrongType(
        rightType: String,
        wrongType: value.runtimeType,
        parserType: UriParser,
        configs: [value],
      );
    }

    final uri = Uri.parse(value);

    return uri;
  }
}
