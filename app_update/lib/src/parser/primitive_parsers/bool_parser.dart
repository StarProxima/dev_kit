import '../update_config_exception.dart';

class BoolParser {
  const BoolParser();

  // ignore: prefer-boolean-prefixes
  bool? parse(
    // ignore: avoid-dynamic
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! bool) throw const UpdateConfigException();

    return value;
  }
}
