import '../update_app_settings/update_app_settings_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';

class UpdateRulesContainer {
  final List<UpdateRuleConfig<UpdateContentConfig>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules;

  const UpdateRulesContainer({
    required this.contentRules,
    required this.settingsRules,
    required this.appSettingsRules,
  });
}
