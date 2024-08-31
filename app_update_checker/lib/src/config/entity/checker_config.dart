import 'release.dart';
import 'release_settings.dart';
import 'stores/store.dart';

class CheckerConfig {
  final ReleaseSettings releaseSettings;
  final List<Store> stores;
  final List<Release> releases;
  final Map<String, dynamic> customData;

  const CheckerConfig({
    required this.releaseSettings,
    required this.stores,
    required this.releases,
    required this.customData,
  });
}
