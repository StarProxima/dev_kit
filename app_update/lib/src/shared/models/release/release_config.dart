import 'package:pub_semver/pub_semver.dart';

import '../../mergeable.dart';
import '../release_platrform/release_platrform_config.dart';
import '../release_source/release_source_config.dart';
import '../update_app_settings/update_app_settings_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';
import 'release_override_config.dart';

class ReleaseConfig {
  final Version? version;
  final DateTime? date;
  final List<ReleaseSourceConfig>? sources;
  final List<UpdateRuleConfig<UpdateContentConfig?>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig?>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppSettingsConfig?>>? appSettingsRules;
  final Map<String, dynamic>? customData;

  const ReleaseConfig({
    this.version,
    this.date,
    this.sources,
    this.contentRules,
    this.settingsRules,
    this.appSettingsRules,
    this.customData,
  });

  const ReleaseConfig.byRequired({
    required this.version,
    required this.date,
    required this.sources,
    required this.contentRules,
    required this.settingsRules,
    required this.appSettingsRules,
    required this.customData,
  });

  ReleaseConfig overrideBy({
    ReleaseSourceConfig? source,
    ReleasePlatformConfig? platform,
  }) =>
      ReleaseConfig.byRequired(
        version: platform?.releaseOverride?.version ?? source?.releaseOverride?.version ?? version,
        date: platform?.releaseOverride?.date ?? source?.releaseOverride?.date ?? date,
        sources: sources,
        contentRules: Mergeable.mergeRules(
          contentRules,
          source?.contentRules,
          platform?.contentRules,
        ),
        settingsRules: Mergeable.mergeRules(
          settingsRules,
          source?.settingsRules,
          platform?.settingsRules,
        ),
        appSettingsRules: Mergeable.mergeRules(
          appSettingsRules,
          source?.appSettingsRules,
          platform?.appSettingsRules,
        ),
        customData: Mergeable.mergeCustomData(
          customData,
          source?.customData,
          source?.releaseOverride?.customData,
          platform?.customData,
          platform?.releaseOverride?.customData,
        ),
      );
}
