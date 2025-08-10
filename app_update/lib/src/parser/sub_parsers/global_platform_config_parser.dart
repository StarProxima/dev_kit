// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../shared/models/global_platform/global_platform_config.dart';
import '../base_parsers/update_platform_parser.dart';
import '../base_parsers/update_rules_part_parser.dart';
import '../common.dart';
import 'global_source_config_parser.dart';

class GlobalPlatformConfigParser {
  static const _updatePlatformParser = UpdatePlatformParser();
  static const _updateRulesPartParser = UpdateRulesPartParser();

  const GlobalPlatformConfigParser();

  GlobalPlatformConfig? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    // Short syntax
    if (value is String) {
      final name = _updatePlatformParser.parse(value);

      if (name == null) {
        throw const UpdateConfigException();
      }

      return GlobalPlatformConfig.byRequired(
        platformName: name,
        contentRules: null,
        settingsRules: null,
        appStatusRules: null,
        customData: null,
      );
    }

    if (value is! Map) {
      throw const UpdateConfigException();
    }

    final map = Map<String, dynamic>.from(value);

    // name
    final nameValue = map.remove('name');
    final name = _updatePlatformParser.parse(nameValue);

    // Разрешаем любые значения name, если строка не пуста
    if (name == null || (name.name.isEmpty)) {
      throw const UpdateConfigException();
    }

    // rules
    final rules = _updateRulesPartParser.parse(map);

    return GlobalPlatformConfig.byRequired(
      platformName: name,
      contentRules: rules?.contentRules,
      settingsRules: rules?.settingsRules,
      appStatusRules: rules?.appStatusRules,
      customData: map,
    );
  }
}
