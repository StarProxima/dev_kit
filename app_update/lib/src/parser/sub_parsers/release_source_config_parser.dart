// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../models/release_source/release_source_config.dart';
import '../base_parsers/custom_params_parser.dart';
import '../base_parsers/update_rules_container_parser.dart';
import '../base_parsers/update_source_name_parser.dart';
import '../parse_config_exeption.dart';
import 'release_override_config_parser.dart';
import 'release_platrform_config_parser.dart';

class ReleaseSourceConfigParser {
  static const _updateSourceNameParser = UpdateSourceNameParser();
  static const _releasePlatformConfigParser = ReleasePlatformConfigParser();
  static const _releaseOverrideConfigParser = ReleaseOverrideConfigParser();
  static const _updateRulesPartParser = UpdateRulesPartParser();
  static const _customParamsParser = CustomParamsParser();

  const ReleaseSourceConfigParser();

  ReleaseSourceConfig? parse(
    Object? value, {
    required bool isDebug,
  }) {
    if (value == null) return null;

    // Short syntax
    if (value is String) {
      final name = _updateSourceNameParser.parse(value);
      if (name == null) throw const ParseConfigException();

      return ReleaseSourceConfig.byRequired(
        sourceName: name,
        platforms: null,
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
        parserType: ReleaseSourceConfigParser,
        configs: [value],
      );
    }

    final map = Map<String, dynamic>.from(value);

    // customParams
    final customParamsValue = map.remove('custom_params');
    final customParams = _customParamsParser.parse(customParamsValue);

    // name
    final nameValue = map.remove('name');
    final name = _updateSourceNameParser.parse(nameValue);
    if (name == null) throw const ParseConfigException();

    // platforms
    final platformsValue = map.remove('platforms');
    if (platformsValue is! List?) throw const ParseConfigException();

    final platforms = platformsValue
        ?.map((value) =>
            _releasePlatformConfigParser.parse(value, isDebug: isDebug))
        .nonNulls
        .toList();

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
        parserType: ReleaseSourceConfigParser,
        configs: [value],
      );
    }

    return ReleaseSourceConfig.byRequired(
      sourceName: name,
      platforms: platforms,
      releaseOverride: releaseOverride,
      contentRules: rules.contentRules,
      settingsRules: rules.settingsRules,
      appSettingsRules: rules.appSettingsRules,
      customParams: customParams,
    );
  }
}
