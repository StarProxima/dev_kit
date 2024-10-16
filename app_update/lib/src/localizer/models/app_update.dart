import 'package:pub_semver/pub_semver.dart';

import '../../shared/app_version_status.dart';
import 'release.dart';
import 'update_config.dart';

class AppUpdate {
  final String appName;
  final Version appVersion;
  final AppVersionStatus appVersionStatus;
  final UpdateConfig config;

  /// Available release from priority source.
  ///
  /// If it is missing, then the source of the application installation is not defined and is not specified.
  final Release? releaseFromTargetSource;

  /// A list of available releases from all sources available on the current application platform.
  ///
  /// If [releaseFromTargetSource] is not set,
  /// then you can try to select one of these, but some may not be on the user's device.
  final List<Release> allReleasesFromAvailableSources;

  const AppUpdate({
    required this.appName,
    required this.appVersion,
    required this.config,
    required this.appVersionStatus,
    required this.releaseFromTargetSource,
    required this.allReleasesFromAvailableSources,
  });
}
