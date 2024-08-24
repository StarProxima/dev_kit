import 'release_dto.dart';
import 'store_dto.dart';

class CheckerConfigDTO {
  const CheckerConfigDTO({
    required this.deprecatedBeforeVersion,
    required this.requiredMinimumVersion,
    required this.stores,
    required this.releases,
    required this.customData,
  });

  final String? deprecatedBeforeVersion;
  final String? requiredMinimumVersion;
  final List<StoreDTO>? stores;
  final List<ReleaseDTO>? releases;
  final Map? customData;
}
