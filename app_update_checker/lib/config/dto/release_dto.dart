import 'package:app_update_checker/config/entity/version.dart';

import 'store_dto.dart';

class ReleaseDTO {
  const ReleaseDTO({
    required this.version,
    required this.isActive,
    required this.isRequired,
    required this.isBroken,
    required this.title,
    required this.description,
    required this.releaseNote,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.stores,
  });

  final Version? version;
  final bool? isActive;
  final bool? isRequired;
  final bool? isBroken;
  final Map<String, String>? title;
  final Map<String, String>? description;
  final Map<String, String>? releaseNote;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final List<StoreDTO>? stores;
}
