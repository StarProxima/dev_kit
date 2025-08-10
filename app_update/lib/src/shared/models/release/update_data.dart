import 'package:pub_semver/pub_semver.dart';

import '../../update_entities/update_platform.dart';
import '../../update_entities/update_source_name.dart';
import '../update_app_settings/update_app_settings_config.dart';
import '../update_content/update_content_config.dart';
import '../update_rule/update_rule_config.dart';
import '../update_settings/update_settings_config.dart';

class UpdateData {
  final Version version;
  final DateTime? date;
  final UpdateSourceName sourceName;
  final UpdatePlatform platform;
  final List<UpdateRuleConfig<UpdateContentConfig?>>? contentRules;
  final List<UpdateRuleConfig<UpdateSettingsConfig?>>? settingsRules;
  final List<UpdateRuleConfig<UpdateAppSettingsConfig?>>? appSettingsRules;
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
}
