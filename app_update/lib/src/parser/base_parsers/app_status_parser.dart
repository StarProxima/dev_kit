import '../../entities/app_status.dart';
import '../common.dart';

class AppStatusParser {
  const AppStatusParser();

  AppStatus? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! String) throw const UpdateConfigException();

    return AppStatus.custom(value);
  }
}
