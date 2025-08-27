import 'package:pub_semver/pub_semver.dart';

import '../../entities/update_platform.dart';
import '../../entities/update_source_name.dart';
import '../../utils/mergeable.dart';
import '../release_platrform/release_platrform_config.dart';
import '../release_source/release_source_config.dart';
import '../update_app_settings/update_app_settings_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';
import 'release_config.dart';

class UpdateData {
  final Version version;
  final DateTime date;
  final UpdateSourceName sourceName;
  final UpdatePlatform platform;
  final List<UpdateRuleConfig<UpdateContentConfig>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules;
  final Map<String, dynamic>? customData;

  const UpdateData({
    required this.version,
    required this.date,
    required this.sourceName,
    required this.platform,
    required this.contentRules,
    required this.settingsRules,
    required this.appSettingsRules,
    required this.customData,
  });

  UpdateData copyWith({
    Version? version,
    DateTime? date,
    UpdateSourceName? sourceName,
    UpdatePlatform? platform,
    List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
    List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
    List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
    Map<String, dynamic>? customData,
  }) =>
      UpdateData(
        version: version ?? this.version,
        date: date ?? this.date,
        sourceName: sourceName ?? this.sourceName,
        platform: platform ?? this.platform,
        contentRules: contentRules ?? this.contentRules,
        settingsRules: settingsRules ?? this.settingsRules,
        appSettingsRules: appSettingsRules ?? this.appSettingsRules,
        customData: Mergeable.mergeCustomData(this.customData, customData),
      );
}

extension UpdateDataToReleaseConfig on UpdateData {
  ReleaseConfig toReleaseConfig() => ReleaseConfig.byRequired(
        version: version,
        date: date,
        sources: [
          ReleaseSourceConfig(
            sourceName: sourceName,
            platforms: [
              ReleasePlatformConfig(platformName: platform),
            ],
          ),
        ],
        contentRules: contentRules,
        settingsRules: settingsRules,
        appSettingsRules: appSettingsRules,
        customData: customData,
      );
}
