import 'package:pub_semver/pub_semver.dart';

import '../../shared/update_platform.dart';
import '../sub_parsers/update_app_status_config/update_app_status_config.dart';
import 'update_content_config.dart';
import 'update_rule_config.dart';
import 'update_settings_config.dart';

class ReleaseConfig {
  final Version? version;
  final DateTime? date;
  final List<ReleaseSourceConfig>? sources;
  final List<UpdateRuleConfig<UpdateContentConfig>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppStatusConfig>>? appStatusConditions;
  final Map<String, dynamic>? customData;

  const ReleaseConfig({
    this.version,
    this.date,
    this.sources,
    this.contentRules,
    this.settingsRules,
    this.appStatusConditions,
    this.customData,
  });

  const ReleaseConfig.byRequired({
    required this.version,
    required this.date,
    required this.sources,
    required this.contentRules,
    required this.settingsRules,
    required this.appStatusConditions,
    required this.customData,
  });
}

class ReleaseSourceConfig {
  final String? name;
  final Uri? url;
  final List<ReleasePlatformConfig>? platforms;
  final ReleaseConfig? releaseOverride;
  final Map<String, dynamic>? customData;

  const ReleaseSourceConfig({
    this.name,
    this.url,
    this.platforms,
    this.releaseOverride,
    this.customData,
  });

  const ReleaseSourceConfig.byRequired({
    required this.name,
    required this.url,
    required this.platforms,
    required this.releaseOverride,
    required this.customData,
  });
}

class ReleasePlatformConfig {
  final UpdatePlatform platform;
  final ReleaseSourceConfig? sourceOverride;
  final Map<String, dynamic>? customData;

  const ReleasePlatformConfig({
    required this.platform,
    required this.sourceOverride,
    required this.customData,
  });

  const ReleasePlatformConfig.byRequired({
    required this.platform,
    this.sourceOverride,
    this.customData,
  });
}
