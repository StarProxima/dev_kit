import '../../stores/store.dart';
import 'release_data.dart';
import 'release_settings.dart';

class UpdateConfigData {
  final ReleaseSettings releaseSettings;
  final List<Store> stores;
  final List<ReleaseData> releases;
  final Map<String, dynamic>? customData;

  const UpdateConfigData({
    required this.releaseSettings,
    required this.stores,
    required this.releases,
    required this.customData,
  });
}
