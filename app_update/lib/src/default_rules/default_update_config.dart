import '../entities/update_source.dart';
import '../models/update_config/update_config.dart';
import 'app_settings/default_update_app_settings.dart';
import 'content/default_update_content.dart';
import 'settings/default_update_settings_rules.dart';

// ignore: prefer-static-class
final defaultUpdateConfig = UpdateConfig(
  contentRules: defaultUpdateContentRules,
  settingsRules: defaultUpdateSettingsRules,
  appSettingsRules: defaultUpdateAppSettingsRules,
  sources: [
    for (final source in UpdateSource.values) source.toGlobalSourceConfig(),
  ],
);
