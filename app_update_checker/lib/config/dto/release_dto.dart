import 'dart:ui';

import '../entity/version.dart';

import 'store_dto.dart';

class ReleaseDTO {
  final Version version;
  final bool? isActive;
  final bool? isRequired;
  final bool? isBroken;
  final Map<Locale, String>? title;
  final Map<Locale, String>? description;
  final Map<Locale, String>? releaseNote;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final List<StoreDTO>? stores;
  final Map<String, dynamic>? customData;

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
    required this.customData,
  });
}
