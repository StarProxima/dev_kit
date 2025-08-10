// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../shared/models/update_app_status/update_app_status_config.dart';
import '../base_parsers/app_status_parser.dart';
import '../common.dart';

class UpdateAppStatusConfigParser {
  static const _appStatusParser = AppStatusParser();

  const UpdateAppStatusConfigParser();

  UpdateAppStatusConfig? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! Map) {
      throw const UpdateConfigException();
    }

    final map = Map<String, dynamic>.from(value);

    // appStatus
    final appStatusValue = map.remove('app_status');
    final appStatus = _appStatusParser.parse(
      appStatusValue,
    );

    return UpdateAppStatusConfig.byRequired(
      appStatus: appStatus,
      customData: map,
    );
  }
}
