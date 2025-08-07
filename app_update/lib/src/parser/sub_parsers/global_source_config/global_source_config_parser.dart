// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../base_parsers/update_source_parser.dart';
import '../../primitive_parsers/list_or_value_parser.dart';
import '../../primitive_parsers/uri_parser.dart';
import '../../common.dart';
import '../global_platform_config/global_platform_config.dart';
import '../global_platform_config/global_platform_config_parser.dart';
import '../update_app_status_config/update_app_status_config_parser.dart';
import '../update_content_config/update_content_config_parser.dart';
import '../update_rule_config/update_rule_config_parser.dart';
import '../update_settings_config/update_settings_config_parser.dart';
import 'global_source_config.dart';

class GlobalSourceConfigParser {
  static const _updateSourceParser = UpdateSourceParser();
  static const _uriParser = UriParser();
  static const _globalPlatformConfigParser = GlobalPlatformConfigParser();
  static const _updateRuleConfigParser = UpdateRuleConfigParser();
  static const _listOrValueParser = ListOrValueParser();
  static const _updateContentConfigParser = UpdateContentConfigParser();
  static const _updateSettingsConfigParser = UpdateSettingsConfigParser();
  static const _updateAppStatusConfigParser = UpdateAppStatusConfigParser();

  const GlobalSourceConfigParser();

  GlobalSourceConfig? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! Map) {
      throw const UpdateConfigException();
    }

    final map = Map<String, dynamic>.from(value);

    // name
    final nameValue = map.remove('name');
    final name = _updateSourceParser.parse(nameValue);

    // url
    final urlValue = map.remove('url');
    final url = _uriParser.parse(urlValue);

    // platforms
    final platformsValue = map.remove('platforms');
    if (platformsValue is! List<dynamic>?) {
      throw const UpdateConfigException();
    }
    final platforms = platformsValue
        ?.map(_globalPlatformConfigParser.parse)
        .where((e) => e != null)
        .cast<GlobalPlatformConfig>()
        .toList();

    // contentRules
    final contentRulesRawValue = map.remove('content_rules');
    final contentRulesValue = _listOrValueParser.parse(contentRulesRawValue);

    final contentRules = contentRulesValue
        ?.map((value) => _updateRuleConfigParser.parse(
              value,
              dataParser: _updateContentConfigParser.parse,
            ))
        .nonNulls
        .toList();

    // settingsRules
    final settingsRulesRawValue = map.remove('settings_rules');
    final settingsRulesValue = _listOrValueParser.parse(settingsRulesRawValue);

    final settingsRules = settingsRulesValue
        ?.map((value) => _updateRuleConfigParser.parse(
              value,
              dataParser: _updateSettingsConfigParser.parse,
            ))
        .nonNulls
        .toList();

    // appStatusRules
    final appStatusRulesRawValue = map.remove('app_status_rules');
    final appStatusRulesValue = _listOrValueParser.parse(appStatusRulesRawValue);
    final appStatusRules = appStatusRulesValue
        ?.map((value) => _updateRuleConfigParser.parse(
              value,
              dataParser: _updateAppStatusConfigParser.parse,
            ))
        .nonNulls
        .toList();

    return GlobalSourceConfig.byRequired(
      source: name,
      url: url,
      platforms: platforms,
      contentRules: contentRules,
      settingsRules: settingsRules,
      appStatusRules: appStatusRules,
      customData: map,
    );
  }
}
