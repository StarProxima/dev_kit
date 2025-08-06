// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../primitive_parsers/date_time_parser.dart';
import '../../primitive_parsers/list_or_value_parser.dart';
import '../../primitive_parsers/version_parser.dart';
import '../../update_config_exception.dart';
import '../release_source_config/release_source_config.dart';
import '../release_source_config/release_source_config_parser.dart';
import '../update_app_status_config/update_app_status_config.dart';
import '../update_app_status_config/update_app_status_config_parser.dart';
import '../update_content_config/update_content_config.dart';
import '../update_content_config/update_content_config_parser.dart';
import '../update_rule_config/update_rule_config.dart';
import '../update_rule_config/update_rule_config_parser.dart';
import '../update_settings_config/update_settings_config.dart';
import '../update_settings_config/update_settings_config_parser.dart';
import 'release_config.dart';

class ReleaseConfigParser {
  static const _versionParser = VersionParser();
  static const _dateTimeParser = DateTimeParser();
  static const _releaseSourceConfigParser = ReleaseSourceConfigParser();

  static const _updateRuleConfigParser = UpdateRuleConfigParser();
  static const _listOrValueParser = ListOrValueParser();
  static const _updateContentConfigParser = UpdateContentConfigParser();
  static const _updateSettingsConfigParser = UpdateSettingsConfigParser();
  static const _updateAppStatusConfigParser = UpdateAppStatusConfigParser();

  const ReleaseConfigParser();

  ReleaseConfig? parse(
    dynamic value,
  ) {
    if (value is! Map<String, dynamic>?) {
      throw const UpdateConfigException();
    }

    if (value == null) return null;

    // version
    final versionValue = value.remove('version');
    final version = _versionParser.parse(versionValue);

    // date
    final dateValue = value.remove('date');
    final date = _dateTimeParser.parse(dateValue);

    // sources
    final sourcesRawValue = value.remove('sources');
    final sourcesValue = _listOrValueParser.parse(sourcesRawValue);

    final sources = sourcesValue
        ?.map(_releaseSourceConfigParser.parse)
        .whereType<ReleaseSourceConfig>()
        .toList();

    // contentRules
    final contentRulesRawValue = value.remove('content_rules');
    final contentRulesValue = _listOrValueParser.parse(contentRulesRawValue);

    final contentRules = contentRulesValue
        ?.map((value) => _updateRuleConfigParser.parse(
              value,
              dataParser: _updateContentConfigParser.parse,
            ))
        .whereType<UpdateRuleConfig<UpdateContentConfig>>()
        .toList();

    // settingsRules
    final settingsRulesRawValue = value.remove('settings_rules');
    final settingsRulesValue = _listOrValueParser.parse(settingsRulesRawValue);

    final settingsRules = settingsRulesValue
        ?.map((value) => _updateRuleConfigParser.parse(
              value,
              dataParser: _updateSettingsConfigParser.parse,
            ))
        .whereType<UpdateRuleConfig<UpdateSettingsConfig>>()
        .toList();

    // appStatusRules
    final appStatusRulesRawValue = value.remove('app_status_rules');
    final appStatusRulesValue = _listOrValueParser.parse(appStatusRulesRawValue);
    final appStatusRules = appStatusRulesValue
        ?.map((value) => _updateRuleConfigParser.parse(
              value,
              dataParser: _updateAppStatusConfigParser.parse,
            ))
        .whereType<UpdateRuleConfig<UpdateAppStatusConfig>>()
        .toList();

    return ReleaseConfig.byRequired(
      version: version,
      date: date,
      sources: sources,
      contentRules: contentRules,
      settingsRules: settingsRules,
      appStatusRules: appStatusRules,
      customData: value,
    );
  }
}
