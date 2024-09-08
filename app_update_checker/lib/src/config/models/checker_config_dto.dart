import 'release_dto.dart';
import 'release_settings_dto.dart';
import 'store_dto.dart';

class CheckerConfigDTO {
  final ReleaseSettingsDTO releaseSettings;
  final List<StoreDTO> stores;
  final List<ReleaseDTO> releases;
  final Map<String, dynamic> customData;

  const CheckerConfigDTO({
    required this.releaseSettings,
    required this.stores,
    required this.releases,
    required this.customData,
  });
}
