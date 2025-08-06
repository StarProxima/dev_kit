import '../../shared/app_status.dart';
import '../update_config_exception.dart';

class AppStatusParser {
  const AppStatusParser();

  AppStatus? parse(
    dynamic value,
  ) {
    if (value! is String?) throw const UpdateConfigException();

    if (value == null) return null;

    return AppStatus.custom(value);
  }
}
