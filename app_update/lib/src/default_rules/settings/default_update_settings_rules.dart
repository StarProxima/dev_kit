import '../../shared/entities/app_status.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/models/update_settings/update_settings_config.dart';

final List<UpdateRuleConfig<UpdateSettingsConfig>> defaultUpdateSettingsRules =
    [
  const UpdateRuleConfig(
    data: UpdateSettingsConfig.byRequired(
      shouldShow: true,
      canSkip: false,
      canPostpone: true,
      skipReleaseDelay: Duration(days: 180),
      skipAllReleasesDelay: Duration(days: 1),
      postponeReleaseDelay: Duration(days: 7),
      postponeAllReleasesDelay: Duration(days: 1),
      customData: null,
    ),
  ),
  const UpdateRuleConfig(
    appStatuses: [AppStatus.unsupported],
    data: UpdateSettingsConfig(
      canSkip: false,
      canPostpone: false,
    ),
  ),
  const UpdateRuleConfig(
    appStatuses: [AppStatus.outdated],
    data: UpdateSettingsConfig(
      canSkip: false,
      canPostpone: true,
      postponeReleaseDelay: Duration(days: 1),
    ),
  ),
];
