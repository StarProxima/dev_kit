import '../../linker/models/release_settings.dart';
import '../../stores/store.dart';
import 'release.dart';

class UpdateConfig {
  final ReleaseSettings releaseSettings;
  final List<Store> stores;
  final List<Release> releases;
  final Map<String, dynamic> customData;

  const UpdateConfig({
    required this.releaseSettings,
    required this.stores,
    required this.releases,
    required this.customData,
  });
}
