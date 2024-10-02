import '../models/update_config_exception.dart';

class BoolParser {
  const BoolParser();

  // ignore: prefer-boolean-prefixes
  bool? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is bool?) return value;
    if (isDebug) throw const UpdateConfigException();

    return null;
  }
}
