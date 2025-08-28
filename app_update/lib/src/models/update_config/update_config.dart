import '../global_source/global_source_config.dart';
import '../release/release_config.dart';
import '../update_app_settings/update_app_settings_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';

class UpdateConfig {
  final List<UpdateRuleConfig<UpdateContentConfig>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules;
  final List<GlobalSourceConfig>? sources;
  final List<ReleaseConfig> releases;
  final Map<String, dynamic>? customParams;

  const UpdateConfig({
    this.contentRules,
    this.settingsRules,
    this.appSettingsRules,
    this.sources,
    this.releases = const [],
    this.customParams,
  });

  const UpdateConfig.byRequired({
    required this.contentRules,
    required this.settingsRules,
    required this.appSettingsRules,
    required this.sources,
    required this.releases,
    required this.customParams,
  });
}
