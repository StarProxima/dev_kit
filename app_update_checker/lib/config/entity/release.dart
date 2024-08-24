import 'dart:ui';

import 'package:app_update_checker/config/entity/stores/store.dart';

import 'version.dart';

class Release {
  const Release({
    required this.version,
    required this.buildNumber,
    required this.isActive,
    required this.isRequired,
    required this.isBroken,
    required this.title,
    required this.description,
    required this.releaseNote,
    required this.stores,
  });

  final Version version;
  final int buildNumber;
  final bool isActive;
  final bool isRequired;
  final bool isBroken;
  final Map<Locale, String> title;
  final Map<Locale, String> description;
  final Map<Locale, String> releaseNote;
  final List<Store> stores;
  // - googlePlay
  // - appStore
  // - ruStore
  // - store: github
  //   platforms:
  //     - android
  //     - ios
  //     - aurora
}
