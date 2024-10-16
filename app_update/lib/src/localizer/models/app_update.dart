import 'package:pub_semver/pub_semver.dart';

import '../../shared/app_version_status.dart';
import 'release.dart';
import 'update_config.dart';

class AppUpdate {
  final String appName;
  final Version appVersion;
  final AppVersionStatus appVersionStatus;
  final UpdateConfig config;
  final Release release;

  const AppUpdate({
    required this.appName,
    required this.appVersion,
    required this.config,
    required this.appVersionStatus,
    required this.release,
  });
}
