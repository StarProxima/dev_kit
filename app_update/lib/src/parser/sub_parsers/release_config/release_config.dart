import 'package:pub_semver/pub_semver.dart';

import '../release_source_config/release_source_config.dart';
import '../update_app_status_config/update_app_status_config.dart';
import '../update_content_config/update_content_config.dart';
import '../update_rule_config/update_rule_config.dart';
import '../update_settings_config/update_settings_config.dart';

class ReleaseConfig {
  final Version? version;
  final DateTime? date;
  final List<ReleaseSourceConfig>? sources;
  final List<UpdateRuleConfig<UpdateContentConfig>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppStatusConfig>>? appStatusRules;
  final Map<String, dynamic>? customData;

  const ReleaseConfig({
    this.version,
    this.date,
    this.sources,
    this.contentRules,
    this.settingsRules,
    this.appStatusRules,
    this.customData,
  });

  const ReleaseConfig.byRequired({
    required this.version,
    required this.date,
    required this.sources,
    required this.contentRules,
    required this.settingsRules,
    required this.appStatusRules,
    required this.customData,
  });
}
