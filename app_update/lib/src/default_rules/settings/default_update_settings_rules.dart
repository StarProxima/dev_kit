import '../../entities/app_status.dart';
import '../../models/update_rule/update_rule_config.dart';
import '../../models/update_settings/update_settings_config.dart';

// ignore: prefer-static-class
final defaultUpdateSettingsRules = [
  const UpdateRuleConfig(
    data: UpdateSettingsConfig.byRequired(
      shouldShow: true,
      canSkip: false,
      canPostpone: true,
      skipReleaseDelay: Duration(days: 180),
      skipAllReleasesDelay: Duration(days: 1),
      postponeReleaseDelay: Duration(days: 7),
      // ignore: no-equal-arguments
      postponeAllReleasesDelay: Duration(days: 1),
      customData: null,
    ),
  ),
  const UpdateRuleConfig(
    appStatusIs: [AppStatus.unsupported],
    data: UpdateSettingsConfig(
      canSkip: false,
      canPostpone: false,
    ),
  ),
  const UpdateRuleConfig(
    appStatusIs: [AppStatus.outdated],
    data: UpdateSettingsConfig(
      canSkip: false,
      canPostpone: true,
      postponeReleaseDelay: Duration(days: 1),
    ),
  ),
];
