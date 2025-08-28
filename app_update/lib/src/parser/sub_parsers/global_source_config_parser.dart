// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../models/global_platform/global_platform_config.dart';
import '../../models/global_source/global_source_config.dart';
import '../base_parsers/custom_params_parser.dart';
import '../base_parsers/update_rules_container_parser.dart';
import '../base_parsers/update_source_name_parser.dart';
import '../parse_config_exeption.dart';
import 'global_platform_config_parser.dart';

class GlobalSourceConfigParser {
  static const _updateSourceNameParser = UpdateSourceNameParser();
  static const _globalPlatformConfigParser = GlobalPlatformConfigParser();
  static const _updateRulesPartParser = UpdateRulesPartParser();
  static const _customParamsParser = CustomParamsParser();

  const GlobalSourceConfigParser();

  GlobalSourceConfig? parse(
    Object? value,
  ) {
    if (value == null) return null;

    if (value is! Map) {
      throw ParseConfigException.wrongType(
        rightType: Map,
        wrongType: value.runtimeType,
        parserType: GlobalSourceConfigParser,
        configs: [value],
      );
    }

    final map = Map<String, dynamic>.from(value);

    // customData
    final customParamsValue = map.remove('custom_params');
    final customData = _customParamsParser.parse(customParamsValue);

    // name
    final nameValue = map.remove('name');
    final name = _updateSourceNameParser.parse(nameValue);

    if (name == null) {
      throw const ParseConfigException();
    }

    // platforms
    final platformsValue = map.remove('platforms');
    if (platformsValue is! List<Object?>?) {
      throw const ParseConfigException();
    }
    final platforms = platformsValue
        ?.map(_globalPlatformConfigParser.parse)
        .where((e) => e != null)
        .cast<GlobalPlatformConfig>()
        .toList();

    // rules
    final rules = _updateRulesPartParser.parse(map);

    // Проверяем, что не осталось неизвестных параметров
    if (map.isNotEmpty) {
      throw ParseConfigException.unexpectedParams(
        params: map,
        parserType: GlobalSourceConfigParser,
        configs: [value],
      );
    }

    return GlobalSourceConfig.byRequired(
      sourceName: name,
      platforms: platforms,
      contentRules: rules.contentRules,
      settingsRules: rules.settingsRules,
      appSettingsRules: rules.appSettingsRules,
      customData: customData,
    );
  }
}
