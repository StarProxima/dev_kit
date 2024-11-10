import '../../shared/update_settings_container.dart';
import '../../shared/update_text_container.dart';
import 'release_config.dart';
import 'source_config.dart';
import 'versions_settings_config.dart';

class UpdateConfigModel {
  final UpdateTextConfigContainer? text;
  final UpdateSettingsConfigContainer? settings;
  final VersionSettingsConfig? versionSettings;
  final List<GlobalSourceConfig>? sources;
  final List<ReleaseConfig> releases;
  final Map<String, dynamic>? customData;

  const UpdateConfigModel({
    this.text,
    this.settings,
    this.versionSettings,
    this.sources,
    this.releases = const [],
    this.customData,
  });

  const UpdateConfigModel.byRequired({
    required this.text,
    required this.settings,
    required this.versionSettings,
    required this.sources,
    required this.releases,
    required this.customData,
  });
}
