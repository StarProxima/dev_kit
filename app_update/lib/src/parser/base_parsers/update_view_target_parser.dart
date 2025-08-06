import '../../shared/update_view_target.dart';
import '../update_config_exception.dart';

class UpdateViewTargetParser {
  const UpdateViewTargetParser();

  UpdateViewTarget? parse(
    dynamic value,
  ) {
    if (value is! String?) throw const UpdateConfigException();

    if (value == null) return null;

    return UpdateViewTarget.custom(value);
  }
}
