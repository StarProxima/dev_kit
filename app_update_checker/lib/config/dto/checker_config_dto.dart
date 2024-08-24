import '../entity/version.dart';

import 'release_dto.dart';
import 'store_dto.dart';

class CheckerConfigDTO {
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final Version? deprecatedBeforeVersion;
  final Version? requiredMinimumVersion;
  final List<StoreDTO>? stores;
  final List<ReleaseDTO>? releases;
  final Map<String, dynamic>? customData;

  const CheckerConfigDTO({
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.deprecatedBeforeVersion,
    required this.requiredMinimumVersion,
    required this.stores,
    required this.releases,
    required this.customData,
  });
}
