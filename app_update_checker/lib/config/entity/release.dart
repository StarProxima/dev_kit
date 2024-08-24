import 'dart:ui';

import 'stores/store.dart';
import 'version.dart';

class Release {
  const Release({
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

  final Version version;
  final bool isActive;
  final bool isRequired;
  final bool isBroken;
  final Map<Locale, String> title;
  final Map<Locale, String> description;
  final Map<Locale, String> releaseNote;
  final Duration reminderPeriod;
  final Duration releaseDelay;
  final List<Store> stores;
}
