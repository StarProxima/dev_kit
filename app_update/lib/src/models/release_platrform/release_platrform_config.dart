import '../../entities/update_platform.dart';
import '../release/release_override_config.dart';
import '../../utils/mergeable.dart';
import '../update_app_settings/update_app_settings_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';

class ReleasePlatformConfig {
  final UpdatePlatform platformName;
  final ReleaseOverrideConfig? releaseOverride;
  final List<UpdateRuleConfig<UpdateContentConfig>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules;
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

  ReleasePlatformConfig copyWith({
    UpdatePlatform? platformName,
    ReleaseOverrideConfig? releaseOverride,
    List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
    List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
    List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
    Map<String, dynamic>? customData,
  }) =>
      ReleasePlatformConfig.byRequired(
        platformName: platformName ?? this.platformName,
        releaseOverride: releaseOverride ?? this.releaseOverride,
        contentRules: contentRules ?? this.contentRules,
        settingsRules: settingsRules ?? this.settingsRules,
        appSettingsRules: appSettingsRules ?? this.appSettingsRules,
        customData: Mergeable.mergeCustomData(this.customData, customData),
      );
}
