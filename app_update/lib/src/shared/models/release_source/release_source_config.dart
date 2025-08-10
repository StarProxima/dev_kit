import '../../update_entities/update_source_name.dart';
import '../release/release_override_config.dart';
import '../release_platrform/release_platrform_config.dart';
import '../update_app_status/update_app_status_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';

class ReleaseSourceConfig {
  final UpdateSourceName? sourceName;
  final List<ReleasePlatformConfig>? platforms;
  final ReleaseOverrideConfig? releaseOverride;
  final List<UpdateRuleConfig<UpdateContentConfig?>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig?>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppStatusConfig?>>? appStatusRules;
  final Map<String, dynamic>? customData;

  const ReleaseSourceConfig({
    this.sourceName,
    this.platforms,
    this.releaseOverride,
    this.contentRules,
    this.settingsRules,
    this.appStatusRules,
    this.customData,
  });

  const ReleaseSourceConfig.byRequired({
    required this.sourceName,
    required this.platforms,
    required this.releaseOverride,
    required this.contentRules,
    required this.settingsRules,
    required this.appStatusRules,
    required this.customData,
  });
}
