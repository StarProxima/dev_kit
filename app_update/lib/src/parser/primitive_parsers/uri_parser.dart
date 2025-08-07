import '../common.dart';

class UriParser {
  const UriParser();

  // ignore: prefer-boolean-prefixes
  Uri? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) throw const UpdateConfigException();

    final uri = Uri.parse(value);

    return uri;
  }
}
