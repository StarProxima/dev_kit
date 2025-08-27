import '../../entities/update_view_target.dart';
import '../parse_config_exeption.dart';

class UpdateViewTargetParser {
  const UpdateViewTargetParser();

  UpdateViewTarget? parse(
    Object? value,
  ) {
    if (value == null) return null;

    if (value is! String) {
      throw ParseConfigException.wrongType(
        rightType: String,
        wrongType: value.runtimeType,
        parserType: UpdateViewTargetParser,
        configs: [value],
      );
    }

    return UpdateViewTarget.custom(value);
  }
}
