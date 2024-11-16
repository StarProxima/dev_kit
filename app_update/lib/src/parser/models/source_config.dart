import 'platform_config.dart';
import 'release_config.dart';
import 'update_settings_config_container.dart';
import 'update_text_config_container.dart';
import 'versions_settings_config.dart';

class GlobalSourceConfig {
  final String? name;
  final Uri? url;
  final List<GlobalPlatformConfig>? platforms;
  final UpdateTextConfigContainer? text;
  final UpdateSettingsConfigContainer? settings;
  final VersionSettingsConfig? versionSettings;
  final Map<String, dynamic>? customData;

  const GlobalSourceConfig({
    this.name,
    this.url,
    this.platforms,
    this.text,
    this.settings,
    this.versionSettings,
    this.customData,
  });

  const GlobalSourceConfig.byRequired({
    required this.name,
    required this.url,
    required this.platforms,
    required this.text,
    required this.settings,
    required this.versionSettings,
    required this.customData,
  });
}

class ReleaseSourceConfig {
  final String? name;
  final Uri? url;
  final List<ReleasePlatformConfig>? platforms;
  final ReleaseConfig? release;
  final Map<String, dynamic>? customData;

  const ReleaseSourceConfig({
    this.name,
    this.url,
    this.platforms,
    this.release,
    this.customData,
  });

  const ReleaseSourceConfig.byRequired({
    required this.name,
    required this.url,
    required this.platforms,
    required this.release,
    required this.customData,
  });
}
