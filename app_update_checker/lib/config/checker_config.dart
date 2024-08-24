import 'release.dart';
import 'stores/store.dart';
import 'version.dart';

class CheckerConfig {
  final Version? deprecatedBeforeVersion;
  final Version? requiredMinimumVersion;
  final List<Store> stores;
  final List<Release> releases;
  final Map customData;

  const CheckerConfig({
    required this.deprecatedBeforeVersion,
    required this.requiredMinimumVersion,
    required this.stores,
    required this.releases,
    required this.customData,
  });
}
