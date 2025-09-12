import 'package:pub_semver/pub_semver.dart';

import '../../utils/mergeable.dart';
import '../release_source/release_source_config.dart';
import '../update_app_settings/update_app_settings_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';
import 'release_override_config.dart';

class ReleaseConfig {
  final Version version;
  final DateTime date;
  final List<ReleaseSourceConfig>? sources;
  final List<UpdateRuleConfig<UpdateContentConfig>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules;
  final Map<String, dynamic>? customParams;

  const ReleaseConfig({
    required this.version,
    required this.date,
    this.sources,
    this.contentRules,
    this.settingsRules,
    this.appSettingsRules,
    this.customParams,
  });

  const ReleaseConfig.byRequired({
    required this.version,
    required this.date,
    required this.sources,
    required this.contentRules,
    required this.settingsRules,
    required this.appSettingsRules,
    required this.customParams,
  });

  ReleaseConfig overrideBy(ReleaseOverrideConfig? overrideData) =>
      ReleaseConfig.byRequired(
        version: overrideData?.version ?? version,
        date: overrideData?.date ?? date,
        sources: sources,
        contentRules: contentRules,
        settingsRules: settingsRules,
        appSettingsRules: appSettingsRules,
        customParams: Mergeable.mergeCustomParams(
          customParams,
          overrideData?.customParams,
        ),
      );
}
