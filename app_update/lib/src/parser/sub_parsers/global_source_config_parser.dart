// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../models/global_platform/global_platform_config.dart';
import '../../models/global_source/global_source_config.dart';
import '../base_parsers/update_rules_container_parser.dart';
import '../base_parsers/update_source_name_parser.dart';
import '../parse_config_exeption.dart';
import 'global_platform_config_parser.dart';

class GlobalSourceConfigParser {
  static const _updateSourceNameParser = UpdateSourceNameParser();
  static const _globalPlatformConfigParser = GlobalPlatformConfigParser();
  static const _updateRulesPartParser = UpdateRulesPartParser();

  const GlobalSourceConfigParser();

  GlobalSourceConfig? parse(
    dynamic value,
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

    // name
    final nameValue = map.remove('name');
    final name = _updateSourceNameParser.parse(nameValue);

    if (name == null) {
      throw const ParseConfigException();
    }

    // platforms
    final platformsValue = map.remove('platforms');
    if (platformsValue is! List<dynamic>?) {
      throw const ParseConfigException();
    }
    final platforms = platformsValue
        ?.map(_globalPlatformConfigParser.parse)
        .where((e) => e != null)
        .cast<GlobalPlatformConfig>()
        .toList();

    // rules
    final rules = _updateRulesPartParser.parse(map);

    return GlobalSourceConfig.byRequired(
      sourceName: name,
      platforms: platforms,
      contentRules: rules?.contentRules,
      settingsRules: rules?.settingsRules,
      appSettingsRules: rules?.appSettingsRules,
      customData: map,
    );
  }
}
