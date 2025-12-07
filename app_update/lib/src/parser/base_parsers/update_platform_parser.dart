import '../../entities/update_platform.dart';
import '../parse_config_exeption.dart';

class UpdatePlatformParser {
  const UpdatePlatformParser();

  UpdatePlatform? parse(
    Object? value,
  ) {
    if (value == null) return null;

    if (value is! String) {
      throw ParseConfigException.wrongType(
        rightType: String,
        wrongType: value.runtimeType,
        parserType: UpdatePlatformParser,
        configs: [value],
      );
    }

    return UpdatePlatform.custom(value);
  }
}
