import '../../update_entities/update_source_name.dart';
import '../global_platform/global_platform_config.dart';
import '../update_app_settings/update_app_settings_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';

class GlobalSourceConfig {
  final UpdateSourceName sourceName;
  final List<GlobalPlatformConfig>? platforms;
  final List<UpdateRuleConfig<UpdateContentConfig?>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig?>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppSettingsConfig?>>? appSettingsRules;
  final Map<String, dynamic>? customData;

  const GlobalSourceConfig({
    required this.sourceName,
    this.platforms,
    this.contentRules,
    this.settingsRules,
    this.appSettingsRules,
    this.customData,
  });

  const GlobalSourceConfig.byRequired({
    required this.sourceName,
    required this.platforms,
    required this.contentRules,
    required this.settingsRules,
    required this.appSettingsRules,
    required this.customData,
  });
}
