import '../update_config_exception.dart';

class StringParser {
  const StringParser();

  String? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value is! String?) throw const UpdateConfigException();

    return value;
  }
}
