// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../models/release_platrform/release_platrform_config.dart';
import '../base_parsers/custom_params_parser.dart';
import '../base_parsers/update_platform_parser.dart';
import '../base_parsers/update_rules_container_parser.dart';
import '../parse_config_exeption.dart';
import 'release_override_config_parser.dart';

class ReleasePlatformConfigParser {
  static const _updatePlatformParser = UpdatePlatformParser();
  static const _releaseOverrideConfigParser = ReleaseOverrideConfigParser();
  static const _updateRulesPartParser = UpdateRulesPartParser();
  static const _customParamsParser = CustomParamsParser();

  const ReleasePlatformConfigParser();

  ReleasePlatformConfig? parse(
    Object? value, {
    required bool isDebug,
  }) {
    if (value == null) return null;

    // Short syntax
    if (value is String) {
      final name = _updatePlatformParser.parse(value);

      if (name == null) {
        throw const ParseConfigException();
      }

      return ReleasePlatformConfig.byRequired(
        platformName: name,
        releaseOverride: null,
        contentRules: null,
        settingsRules: null,
        appSettingsRules: null,
        customParams: null,
      );
    }

    if (value is! Map) {
      throw ParseConfigException.wrongType(
        rightType: Map,
        wrongType: value.runtimeType,
        parserType: ReleasePlatformConfigParser,
        configs: [value],
      );
    }

    final map = Map<String, dynamic>.from(value);

    // customParams
    final customParamsValue = map.remove('custom_params');
    final customParams = _customParamsParser.parse(customParamsValue);

    // name
    final nameValue = map.remove('name');
    final name = _updatePlatformParser.parse(nameValue);

    if (name == null) {
      throw const ParseConfigException();
    }

    // releaseOverride
    final releaseOverrideValue = map.remove('release_override');
    final releaseOverride = _releaseOverrideConfigParser
        .parse(releaseOverrideValue, isDebug: isDebug);

    // rules
    final rules = _updateRulesPartParser.parse(map, isDebug: isDebug);

    // Проверяем, что не осталось неизвестных параметров
    if (isDebug && map.isNotEmpty) {
      throw ParseConfigException.unexpectedParams(
        params: map,
        parserType: ReleasePlatformConfigParser,
        configs: [value],
      );
    }

    return ReleasePlatformConfig.byRequired(
      platformName: name,
      releaseOverride: releaseOverride,
      contentRules: rules.contentRules,
      settingsRules: rules.settingsRules,
      appSettingsRules: rules.appSettingsRules,
      customParams: customParams,
    );
  }
}
