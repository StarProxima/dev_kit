import '../../shared/update_platform.dart';
import '../update_config_exception.dart';

class UpdatePlatformParser {
  const UpdatePlatformParser();

  UpdatePlatform? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) throw const UpdateConfigException();

    return UpdatePlatform.custom(value);
  }
}
