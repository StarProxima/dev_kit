import '../../sources/source.dart';
import 'release_data.dart';
import 'release_settings_data.dart';

class UpdateConfigData {
  final ReleaseSettingsData releaseSettings;
  final List<Source> stores;
  final List<ReleaseData> releases;
  final Map<String, dynamic>? customData;

  const UpdateConfigData({
    required this.releaseSettings,
    required this.stores,
    required this.releases,
    required this.customData,
  });
}
