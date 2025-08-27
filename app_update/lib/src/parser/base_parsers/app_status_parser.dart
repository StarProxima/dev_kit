import '../../entities/app_status.dart';
import '../parse_config_exeption.dart';

class AppStatusParser {
  const AppStatusParser();

  AppStatus? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) {
      throw ParseConfigException.wrongType(
        rightType: String,
        wrongType: value.runtimeType,
        parserType: AppStatusParser,
        configs: [value],
      );
    }

    return AppStatus.custom(value);
  }
}
