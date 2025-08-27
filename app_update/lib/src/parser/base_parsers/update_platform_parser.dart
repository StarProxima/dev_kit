import '../../entities/update_platform.dart';
import '../common.dart';

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
