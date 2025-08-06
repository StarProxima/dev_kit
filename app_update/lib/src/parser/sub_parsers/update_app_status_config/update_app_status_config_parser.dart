// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../base_parsers/app_status_parser.dart';
import '../../update_config_exception.dart';
import 'update_app_status_config.dart';

class UpdateAppStatusConfigParser {
  static const _appStatusParser = AppStatusParser();

  const UpdateAppStatusConfigParser();

  UpdateAppStatusConfig? parse(
    dynamic value,
  ) {
    if (value is! Map<String, dynamic>?) {
      throw const UpdateConfigException();
    }

    if (value == null) return null;

    // appStatus
    final appStatusValue = value.remove('app_status');
    final appStatus = _appStatusParser.parse(
      appStatusValue,
    );

    return UpdateAppStatusConfig.byRequired(
      appStatus: appStatus,
      customData: value,
    );
  }
}
