import 'release_config.dart';
import 'release_settings_config.dart';
import 'store_config.dart';

class UpdateConfigModel {
  final ReleaseSettingsConfig releaseSettings;
  final List<StoreConfig> stores;
  final List<ReleaseConfig> releases;
  final Map<String, dynamic> customData;

  const UpdateConfigModel({
    required this.releaseSettings,
    required this.stores,
    required this.releases,
    required this.customData,
  });
}
