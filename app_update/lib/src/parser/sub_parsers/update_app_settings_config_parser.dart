// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../models/update_app_settings/update_app_settings_config.dart';
import '../base_parsers/app_status_parser.dart';
import '../parse_config_exeption.dart';

class UpdateAppSettingsConfigParser {
  static const _appStatusParser = AppStatusParser();

  const UpdateAppSettingsConfigParser();

  UpdateAppSettingsConfig? parse(
    Object? value,
  ) {
    if (value == null) return null;

    if (value is! Map) {
      throw ParseConfigException.wrongType(
        rightType: Map,
        wrongType: value.runtimeType,
        parserType: UpdateAppSettingsConfigParser,
        configs: [value],
      );
    }

    final map = Map<String, dynamic>.from(value);

    // appStatus
    final appStatusValue = map.remove('app_status');
    final appStatus = _appStatusParser.parse(
      appStatusValue,
    );

    return UpdateAppSettingsConfig.byRequired(
      appStatus: appStatus,
      customData: map,
    );
  }
}
