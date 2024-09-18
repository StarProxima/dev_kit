import '../../linker/models/release_settings_data.dart';
import '../../sources/source.dart';
import 'release.dart';

class UpdateConfig {
  final ReleaseSettingsData releaseSettings;
  final List<Source> sources;
  final List<Release> releases;
  final Map<String, dynamic>? customData;

  const UpdateConfig({
    required this.releaseSettings,
    required this.sources,
    required this.releases,
    required this.customData,
  });
}
