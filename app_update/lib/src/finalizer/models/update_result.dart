import 'dart:ui';

import 'package:pub_semver/pub_semver.dart';

import '../../controller/exceptions.dart';
import '../../shared/update_view_target.dart';
import '../../shared/version_status.dart';
import 'release.dart';
import 'update_config.dart';

class UpdateResult {
  final String appName;
  final Version appVersion;
  final VersionStatus appVersionStatus;
  final Locale? locale;
  final UpdateViewTarget viewTarget;
  final UpdateConfig config;
  final UpdateException? updateException;
  final Release? release;
  final Map<String, dynamic>? customData;

  bool get canUpdate => release != null && updateException == null;

  const UpdateResult({
    required this.appName,
    required this.appVersion,
    required this.config,
    required this.appVersionStatus,
    required this.updateException,
    required this.release,
    required this.locale,
    required this.viewTarget,
    required this.customData,
  });
}
