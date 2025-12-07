import '../../entities/update_platform.dart';

import '../update_app_settings/update_app_settings_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';

class GlobalPlatformConfig {
  final UpdatePlatform platformName;
  final List<UpdateRuleConfig<UpdateContentConfig>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules;
  final Map<String, dynamic>? customParams;

  const GlobalPlatformConfig({
    required this.platformName,
    this.contentRules,
    this.settingsRules,
    this.appSettingsRules,
    this.customParams,
  });

  const GlobalPlatformConfig.byRequired({
    required this.platformName,
    required this.contentRules,
    required this.settingsRules,
    required this.appSettingsRules,
    required this.customParams,
  });
}
