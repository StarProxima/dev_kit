import 'package:app_update_checker/config/entity/version.dart';

import 'release_dto.dart';
import 'store_dto.dart';

class CheckerConfigDTO {
  const CheckerConfigDTO({
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.deprecatedBeforeVersion,
    required this.requiredMinimumVersion,
    required this.stores,
    required this.releases,
    required this.customData,
  });

  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final Version? deprecatedBeforeVersion;
  final Version? requiredMinimumVersion;
  final List<StoreDTO>? stores;
  final List<ReleaseDTO>? releases;
  final Map<String, dynamic>? customData;
}
