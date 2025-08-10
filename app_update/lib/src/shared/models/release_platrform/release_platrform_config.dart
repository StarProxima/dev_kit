import '../../update_entities/update_platform.dart';
import '../release/release_override_config.dart';
import '../update_app_settings/update_app_settings_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';

class ReleasePlatformConfig {
  final UpdatePlatform platformName;
  final ReleaseOverrideConfig? releaseOverride;
  final List<UpdateRuleConfig<UpdateContentConfig?>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig?>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppSettingsConfig?>>? appSettingsRules;
  final Map<String, dynamic>? customData;

  const ReleasePlatformConfig({
    required this.platformName,
    this.releaseOverride,
    this.contentRules,
    this.settingsRules,
    this.appSettingsRules,
    this.customData,
  });

  const ReleasePlatformConfig.byRequired({
    required this.platformName,
    required this.releaseOverride,
    required this.contentRules,
    required this.settingsRules,
    required this.appSettingsRules,
    required this.customData,
  });
}
