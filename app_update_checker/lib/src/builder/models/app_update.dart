import 'dart:ui';

import '../../data/models/checker_config.dart';
import '../../models/version.dart';

import 'release.dart';

class AppUpdate {
  final String appName;
  final Version appVersion;
  final Locale appLocale;
  final CheckerConfig config;
  final Release availableRelease;

  const AppUpdate({
    required this.appName,
    required this.appVersion,
    required this.appLocale,
    required this.config,
    required this.availableRelease,
  });
}
