import '../../shared/update_status_wrapper.dart';
import 'release_config.dart';
import 'release_settings_config.dart';
import 'store_config.dart';
import 'versions_settings_config.dart';

class UpdateConfigModel {
  final UpdateStatusWrapper<ReleaseSettingsConfig?>? releaseSettings;
  final VersionSettingsConfig? versionSettings;
  final List<GlobalSourceConfig>? sources;
  final List<ReleaseConfig> releases;
  final Map<String, dynamic>? customData;

  const UpdateConfigModel({
    required this.releaseSettings,
    required this.versionSettings,
    required this.sources,
    required this.releases,
    required this.customData,
  });
}
