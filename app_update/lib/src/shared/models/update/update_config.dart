import '../global_source/global_source_config.dart';
import '../release/release_config.dart';
import '../update_app_status/update_app_status_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';

class UpdateConfig {
  final List<UpdateRuleConfig<UpdateContentConfig?>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig?>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppStatusConfig?>>? appStatusRules;
  final List<GlobalSourceConfig>? sources;
  final List<ReleaseConfig> releases;
  final Map<String, dynamic>? customData;

  const UpdateConfig({
    this.contentRules,
    this.settingsRules,
    this.appStatusRules,
    this.sources,
    this.releases = const [],
    this.customData,
  });

  const UpdateConfig.byRequired({
    required this.contentRules,
    required this.settingsRules,
    required this.appStatusRules,
    required this.sources,
    required this.releases,
    required this.customData,
  });
}
