// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../primitive_parsers/list_or_value_parser.dart';
import '../../update_config_exception.dart';
import '../global_source_config/global_source_config.dart';
import '../global_source_config/global_source_config_parser.dart';
import '../release_config/release_config.dart';
import '../release_config/release_config_parser.dart';
import '../update_app_status_config/update_app_status_config.dart';
import '../update_app_status_config/update_app_status_config_parser.dart';
import '../update_content_config/update_content_config.dart';
import '../update_content_config/update_content_config_parser.dart';
import '../update_rule_config/update_rule_config.dart';
import '../update_rule_config/update_rule_config_parser.dart';
import '../update_settings_config/update_settings_config.dart';
import '../update_settings_config/update_settings_config_parser.dart';
import 'update_config.dart';

class UpdateConfigParser {
  static const _releaseConfigParser = ReleaseConfigParser();
  static const _globalSourceConfigParser = GlobalSourceConfigParser();
  static const _updateRuleConfigParser = UpdateRuleConfigParser();
  static const _updateContentConfigParser = UpdateContentConfigParser();
  static const _updateSettingsConfigParser = UpdateSettingsConfigParser();
  static const _updateAppStatusConfigParser = UpdateAppStatusConfigParser();
  static const _listOrValueParser = ListOrValueParser();

  const UpdateConfigParser();

  UpdateConfig? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! Map) {
      throw const UpdateConfigException();
    }

    final map = Map<String, dynamic>.from(value);

    // releases
    final releasesRawValue = map.remove('releases');
    final releasesValue = _listOrValueParser.parse(releasesRawValue);

    if (releasesValue == null) throw const UpdateConfigException();

    final releases =
        releasesValue.map(_releaseConfigParser.parse).whereType<ReleaseConfig>().toList();

    // sources
    final sourcesRawValue = map.remove('sources');
    final sourcesValue = _listOrValueParser.parse(sourcesRawValue);

    final sources =
        sourcesValue?.map(_globalSourceConfigParser.parse).whereType<GlobalSourceConfig>().toList();

    // contentRules
    final contentRulesRawValue = map.remove('content_rules');
    final contentRulesValue = _listOrValueParser.parse(contentRulesRawValue);

    final contentRules = contentRulesValue
        ?.map((value) => _updateRuleConfigParser.parse(
              value,
              dataParser: _updateContentConfigParser.parse,
            ))
        .whereType<UpdateRuleConfig<UpdateContentConfig>>()
        .toList();

    // settingsRules
    final settingsRulesRawValue = map.remove('settings_rules');
    final settingsRulesValue = _listOrValueParser.parse(settingsRulesRawValue);

    final settingsRules = settingsRulesValue
        ?.map((value) => _updateRuleConfigParser.parse(
              value,
              dataParser: _updateSettingsConfigParser.parse,
            ))
        .whereType<UpdateRuleConfig<UpdateSettingsConfig>>()
        .toList();

    // appStatusRules
    final appStatusRulesRawValue = map.remove('app_status_rules');
    final appStatusRulesValue = _listOrValueParser.parse(appStatusRulesRawValue);
    final appStatusRules = appStatusRulesValue
        ?.map((value) => _updateRuleConfigParser.parse(
              value,
              dataParser: _updateAppStatusConfigParser.parse,
            ))
        .whereType<UpdateRuleConfig<UpdateAppStatusConfig>>()
        .toList();

    return UpdateConfig.byRequired(
      releases: releases,
      sources: sources,
      contentRules: contentRules,
      settingsRules: settingsRules,
      appStatusRules: appStatusRules,
      customData: map,
    );
  }
}
