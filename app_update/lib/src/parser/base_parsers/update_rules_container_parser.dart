// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../shared/models/update_rule/update_rules_container.dart';
import '../primitive_parsers/list_or_value_parser.dart';
import '../sub_parsers/update_app_status_config_parser.dart';
import '../sub_parsers/update_content_config_parser.dart';
import '../sub_parsers/update_rule_config_parser.dart';
import '../sub_parsers/update_settings_config_parser.dart';

class UpdateRulesPartParser {
  static const _updateRuleConfigParser = UpdateRuleConfigParser();
  static const _listOrValueParser = ListOrValueParser();
  static const _updateContentConfigParser = UpdateContentConfigParser();
  static const _updateSettingsConfigParser = UpdateSettingsConfigParser();
  static const _updateAppStatusConfigParser = UpdateAppStatusConfigParser();

  const UpdateRulesPartParser();

  UpdateRulesContainer? parse(
    Map<String, dynamic> map,
  ) {
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

    final rules = UpdateRulesContainer(
      contentRules: contentRules,
      settingsRules: settingsRules,
      appStatusRules: appStatusRules,
    );

    return rules;
  }
}
