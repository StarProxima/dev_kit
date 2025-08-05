import 'dart:ui';

import 'package:pub_semver/pub_semver.dart';

import '../../controller/exceptions.dart';
import '../../shared/app_status.dart';
import '../../shared/update_locale.dart';
import '../../shared/update_view_target.dart';
import 'release.dart';
import 'update_config.dart';

class UpdateResponse {
  final String appName;
  final Version appVersion;
  final AppStatus appStatus;
  final UpdateLocale? locale;
  final UpdateViewTarget viewTarget;
  final UpdateConfig config;
  final UpdateException? updateException;
  final Release? release;
  final Map<String, dynamic>? customData;

  bool get canUpdate => release != null && updateException == null;

  const UpdateResponse({
    required this.appName,
    required this.appVersion,
    required this.config,
    required this.appStatus,
    required this.updateException,
    required this.release,
    required this.locale,
    required this.viewTarget,
    required this.customData,
  });
}
