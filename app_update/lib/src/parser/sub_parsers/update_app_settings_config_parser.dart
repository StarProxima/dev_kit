// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../models/update_app_settings/update_app_settings_config.dart';
import '../base_parsers/app_status_parser.dart';
import '../base_parsers/custom_params_parser.dart';
import '../parse_config_exeption.dart';

class UpdateAppSettingsConfigParser {
  static const _appStatusParser = AppStatusParser();
  static const _customParamsParser = CustomParamsParser();

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

    // customParams
    final customParamsValue = map.remove('custom_params');
    final customParams = _customParamsParser.parse(customParamsValue);

    // appStatus
    final appStatusValue = map.remove('app_status');
    final appStatus = _appStatusParser.parse(
      appStatusValue,
    );

    // Проверяем, что не осталось неизвестных параметров
    if (map.isNotEmpty) {
      throw ParseConfigException.unexpectedParams(
        params: map,
        parserType: UpdateAppSettingsConfigParser,
        configs: [value],
      );
    }

    return UpdateAppSettingsConfig.byRequired(
      appStatus: appStatus,
      customParams: customParams,
    );
  }
}
