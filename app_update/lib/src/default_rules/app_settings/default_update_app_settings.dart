import '../../entities/app_status.dart';
import '../../models/update_app_settings/update_app_settings_config.dart';
import '../../models/update_rule/update_rule_config.dart';

final List<UpdateRuleConfig<UpdateAppSettingsConfig>>
    defaultUpdateAppSettingsRules = [
  const UpdateRuleConfig(
    data: UpdateAppSettingsConfig.byRequired(
      appStatus: AppStatus.active,
      customData: null,
    ),
  ),
];
