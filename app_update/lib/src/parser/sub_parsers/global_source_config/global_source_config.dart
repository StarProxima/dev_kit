import '../../../shared/update_platform.dart';

import '../update_app_status_config/update_app_status_config.dart';
import '../update_content_config/update_content_config.dart';
import '../update_rule_config/update_rule_config.dart';
import '../update_settings_config/update_settings_config.dart';

class GlobalSourceConfig {
  final String? name;
  final Uri? url;
  final List<GlobalPlatformConfig>? platforms;
  final List<UpdateRuleConfig<UpdateContentConfig>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppStatusConfig>>? appStatusRules;
  final Map<String, dynamic>? customData;

  const GlobalSourceConfig({
    this.name,
    this.url,
    this.platforms,
    this.contentRules,
    this.settingsRules,
    this.appStatusRules,
    this.customData,
  });

  const GlobalSourceConfig.byRequired({
    required this.name,
    required this.url,
    required this.platforms,
    required this.contentRules,
    required this.settingsRules,
    required this.appStatusRules,
    required this.customData,
  });
}

class GlobalPlatformConfig {
  final UpdatePlatform platform;
  final GlobalSourceConfig? sourceOverride;
  final Map<String, dynamic>? customData;

  const GlobalPlatformConfig({
    required this.platform,
    this.sourceOverride,
    this.customData,
  });

  const GlobalPlatformConfig.byRequired({
    required this.platform,
    required this.sourceOverride,
    required this.customData,
  });
}
