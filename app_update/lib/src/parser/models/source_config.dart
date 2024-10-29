import '../../shared/update_status_wrapper.dart';
import 'platform_config.dart';
import 'release_config.dart';
import 'versions_settings_config.dart';

class GlobalSourceConfig {
  final String name;
  final Uri url;
  final List<GlobalPlatformConfig>? platforms;
  final UpdateSettingsConfigContainer? settings;
  final VersionSettingsConfig? versionSettings;
  final Map<String, dynamic>? customData;

  const GlobalSourceConfig({
    required this.name,
    required this.url,
    required this.platforms,
    required this.settings,
    required this.versionSettings,
    required this.customData,
  });
}

class ReleaseSourceConfig {
  final String name;
  final Uri? url;
  final List<ReleasePlatformConfig>? platforms;
  final ReleaseConfig? release;
  final Map<String, dynamic>? customData;

  const ReleaseSourceConfig({
    required this.name,
    required this.url,
    required this.platforms,
    required this.release,
    required this.customData,
  });
}
