import 'dart:async';
import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../parser/models/release_config.dart';
import '../source.dart';

abstract class SourceReleaseFetcher {
  const SourceReleaseFetcher();

  // Return ReleaseData parsed from source's page.
  // Return null if can't parse.
  Future<ReleaseConfig?> fetch({
    required Source? source,
    required Locale locale,
    required PackageInfo packageInfo,
  });
}
