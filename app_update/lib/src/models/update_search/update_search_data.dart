import 'package:pub_semver/pub_semver.dart';

import '../../entities/app_status.dart';
import '../../entities/update_locale.dart';
import '../../entities/update_platform.dart';
import '../../entities/update_source.dart';
import '../../entities/update_view_target.dart';
import '../../utils/mergeable.dart';

class UpdateSearchData {
  final List<UpdateSource> sources;
  final UpdateViewTarget displayTarget;
  final UpdateLocale locale;

  /// Null for search in app_settings_rules.
  final AppStatus? appStatus;

  /// Default [UpdatePlatform.current].
  final UpdatePlatform platform;

  /// App version, uses for compare with rule version.
  final Version appVersion;

  /// Uses for calculate rule date and delay compliance.
  final DateTime currentDate;
  final DateTime? localReleaseDate;
  final DateTime? updateReleaseDate;
  final DateTime? appUpdateDate;
  final DateTime? appInstallDate;

  /// From 0.0 to 1.0, uses for calculate user segmentation compliance.
  final double userSegmentationPointer;

  /// From 0.0 to 1.0, uses for calculate user rollout compliance.
  final double rolloutPointer;

  /// Not used for search, but used for store app data and interpolation.
  final String appName;
  final String appPackageName;

  /// Custom data for search, checks for matches in the customParams in rule.
  final Map<String, dynamic>? customParams;

  const UpdateSearchData({
    required this.platform,
    required this.sources,
    required this.appVersion,
    required this.displayTarget,
    required this.appStatus,
    required this.locale,
    required this.currentDate,
    required this.localReleaseDate,
    required this.updateReleaseDate,
    required this.appUpdateDate,
    required this.appInstallDate,
    required this.userSegmentationPointer,
    required this.rolloutPointer,
    required this.appName,
    required this.appPackageName,
    required this.customParams,
  });

  UpdateSearchData copyWith({
    UpdatePlatform? platform,
    List<UpdateSource>? sources,
    Version? appVersion,
    UpdateViewTarget? displayTarget,
    UpdateLocale? locale,
    AppStatus? appStatus,
    DateTime? currentDate,
    DateTime? localReleaseDate,
    DateTime? updateReleaseDate,
    DateTime? appUpdateDate,
    DateTime? appInstallDate,
    double? userSegmentationPointer,
    double? rolloutPointer,
    String? appName,
    String? appPackageName,
    Map<String, dynamic>? customParams,
  }) =>
      UpdateSearchData(
        platform: platform ?? this.platform,
        sources: sources ?? this.sources,
        appVersion: appVersion ?? this.appVersion,
        displayTarget: displayTarget ?? this.displayTarget,
        appStatus: appStatus ?? this.appStatus,
        locale: locale ?? this.locale,
        currentDate: currentDate ?? this.currentDate,
        localReleaseDate: localReleaseDate ?? this.localReleaseDate,
        updateReleaseDate: updateReleaseDate ?? this.updateReleaseDate,
        appUpdateDate: appUpdateDate ?? this.appUpdateDate,
        appInstallDate: appInstallDate ?? this.appInstallDate,
        userSegmentationPointer:
            userSegmentationPointer ?? this.userSegmentationPointer,
        rolloutPointer: rolloutPointer ?? this.rolloutPointer,
        appName: appName ?? this.appName,
        appPackageName: appPackageName ?? this.appPackageName,
        customParams:
            Mergeable.mergeCustomParams(this.customParams, customParams),
      );
}
