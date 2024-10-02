import '../../shared/update_status_wrapper.dart';
import 'release_config.dart';
import 'source_config.dart';
import 'versions_settings_config.dart';

class UpdateConfigModel {
  final UpdateSettingsConfig? settings;
  final VersionSettingsConfig? versionSettings;
  final List<GlobalSourceConfig>? sources;
  final List<ReleaseConfig> releases;
  final Map<String, dynamic>? customData;

  const UpdateConfigModel({
    required this.settings,
    required this.versionSettings,
    required this.sources,
    required this.releases,
    required this.customData,
  });
}
