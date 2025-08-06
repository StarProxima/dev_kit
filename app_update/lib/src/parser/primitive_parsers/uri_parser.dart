import '../update_config_exception.dart';

class UriParser {
  const UriParser();

  // ignore: prefer-boolean-prefixes
  Uri? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value is! String?) throw const UpdateConfigException();

    if (value == null) return null;

    final uri = Uri.parse(value);

    return uri;
  }
}
