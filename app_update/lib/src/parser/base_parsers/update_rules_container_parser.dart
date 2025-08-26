// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../shared/models/update_content/update_content_config.dart';
import '../../shared/models/update_rule/update_rules_container.dart';
import '../primitive_parsers/list_or_value_parser.dart';
import '../sub_parsers/update_app_settings_config_parser.dart';
import '../sub_parsers/update_content_config_parser.dart';
import '../sub_parsers/update_rule_config_parser.dart';
import '../sub_parsers/update_settings_config_parser.dart';

class UpdateRulesPartParser {
  static const _updateRuleConfigParser = UpdateRuleConfigParser();
  static const _listOrValueParser = ListOrValueParser();
  static const _updateContentConfigParser = UpdateContentConfigParser();
  static const _updateSettingsConfigParser = UpdateSettingsConfigParser();
  static const _updateAppStatusConfigParser = UpdateAppSettingsConfigParser();

  const UpdateRulesPartParser();

  UpdateRulesContainer? parse(
    Map<String, dynamic> map,
  ) {
    // contentRules
    final contentRulesRawValue = map.remove('content');
    final contentRulesValue = _listOrValueParser.parse(contentRulesRawValue);

    final contentRules = contentRulesValue
        ?.map((value) => _updateRuleConfigParser.parse<UpdateContentConfig>(
              value,
              dataParser: _updateContentConfigParser.parse,
            ))
        .nonNulls
        .toList();

    // settingsRules
    final settingsRulesRawValue = map.remove('settings');
    final settingsRulesValue = _listOrValueParser.parse(settingsRulesRawValue);

    final settingsRules = settingsRulesValue
        ?.map((value) => _updateRuleConfigParser.parse(
              value,
              dataParser: _updateSettingsConfigParser.parse,
            ))
        .nonNulls
        .toList();

    // appSettingsRules
    final appSettingsRulesRawValue = map.remove('app_settings');
    final appSettingsRulesValue =
        _listOrValueParser.parse(appSettingsRulesRawValue);
    final appSettingsRules = appSettingsRulesValue
        ?.map((value) => _updateRuleConfigParser.parse(
              value,
              dataParser: _updateAppStatusConfigParser.parse,
            ))
        .nonNulls
        .toList();

    final rules = UpdateRulesContainer(
      contentRules: contentRules,
      settingsRules: settingsRules,
      appSettingsRules: appSettingsRules,
    );

    return rules;
  }
}
