import '../../update_entities/update_source.dart';
import '../global_platform/global_platform_config.dart';
import '../update_app_status/update_app_status_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';

class GlobalSourceConfig {
  final UpdateSource? source;
  final Uri? url;
  final List<GlobalPlatformConfig>? platforms;
  final List<UpdateRuleConfig<UpdateContentConfig?>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig?>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppStatusConfig?>>? appStatusRules;
  final Map<String, dynamic>? customData;

  const GlobalSourceConfig({
    this.source,
    this.url,
    this.platforms,
    this.contentRules,
    this.settingsRules,
    this.appStatusRules,
    this.customData,
  });

  const GlobalSourceConfig.byRequired({
    required this.source,
    required this.url,
    required this.platforms,
    required this.contentRules,
    required this.settingsRules,
    required this.appStatusRules,
    required this.customData,
  });
}
