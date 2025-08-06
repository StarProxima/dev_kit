import '../global_source_config/global_source_config.dart';
import '../release_config/release_config.dart';
import '../update_app_status_config/update_app_status_config.dart';
import '../update_content_config/update_content_config.dart';
import '../update_rule_config/update_rule_config.dart';
import '../update_settings_config/update_settings_config.dart';

class UpdateModelConfig {
  final List<UpdateRuleConfig<UpdateContentConfig>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppStatusConfig>>? appStatusRules;
  final List<GlobalSourceConfig>? sources;
  final List<ReleaseConfig> releases;
  final Map<String, dynamic>? customData;

  const UpdateModelConfig({
    this.contentRules,
    this.settingsRules,
    this.appStatusRules,
    this.sources,
    this.releases = const [],
    this.customData,
  });

  const UpdateModelConfig.byRequired({
    required this.contentRules,
    required this.settingsRules,
    required this.appStatusRules,
    required this.sources,
    required this.releases,
    required this.customData,
  });
}
