import '../models/update_config_exception.dart';

class StringParser {
  const StringParser();

  String? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is String?) return value;
    if (isDebug) throw const UpdateConfigException();

    return null;
  }
}
