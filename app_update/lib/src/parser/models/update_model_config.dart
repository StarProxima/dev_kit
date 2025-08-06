import 'global_source_config.dart';
import 'release_config.dart';
import '../sub_parsers/update_app_status_config/update_app_status_config.dart';
import 'update_content_config.dart';
import 'update_rule_config.dart';
import 'update_settings_config.dart';

class UpdateModelConfig {
  final List<UpdateRuleConfig<UpdateContentConfig>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppStatusConfig>>? appStatusConditions;
  final List<GlobalSourceConfig>? sources;
  final List<ReleaseConfig> releases;
  final Map<String, dynamic>? customData;

  const UpdateModelConfig({
    this.contentRules,
    this.settingsRules,
    this.appStatusConditions,
    this.sources,
    this.releases = const [],
    this.customData,
  });

  const UpdateModelConfig.byRequired({
    required this.contentRules,
    required this.settingsRules,
    required this.appStatusConditions,
    required this.sources,
    required this.releases,
    required this.customData,
  });
}
