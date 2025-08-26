import '../../shared/entities/update_view_target.dart';
import '../common.dart';

class UpdateViewTargetParser {
  const UpdateViewTargetParser();

  UpdateViewTarget? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) throw const UpdateConfigException();

    return UpdateViewTarget.custom(value);
  }
}
