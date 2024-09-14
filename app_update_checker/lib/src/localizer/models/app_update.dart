import 'dart:ui';

import 'package:pub_semver/pub_semver.dart';

import 'release.dart';
import 'update_config.dart';

class AppUpdate {
  final String appName;
  final Version appVersion;
  final Locale appLocale;
  final UpdateConfig config;
  final Release availableRelease;

  const AppUpdate({
    required this.appName,
    required this.appVersion,
    required this.appLocale,
    required this.config,
    required this.availableRelease,
  });
}
