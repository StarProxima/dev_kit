import 'package:pub_semver/pub_semver.dart';

import '../../entities/app_status.dart';
import '../../entities/update_locale.dart';
import '../../entities/update_platform.dart';
import '../../entities/update_source.dart';
import '../../entities/update_view_target.dart';
import '../mergeable.dart';

class UpdateSearchData {
  final UpdatePlatform platform;
  final List<UpdateSource> sources;
  final Version localVersion;
  final UpdateViewTarget displayTarget;
  final UpdateLocale locale;

  /// Not used for search, but used for data and interpolation.
  final String appName;
  final String appPackageName;

  /// Null for search in app_settings_rules.
  final AppStatus? appStatus;

  /// Uses for calculate rule date and delay compliance.
  final DateTime currentDate;
  final DateTime? localReleaseDate;
  final DateTime? updateReleaseDate;

  /// From 0.0 to 1.0, uses for calculate user segmentation compliance.
  final double segmentationPointer;

  /// From 0.0 to 1.0, uses for calculate user rollout compliance.
  final double rolloutPointer;

  /// Custom data for search, checks for matches in the customData in rule.
  final Map<String, dynamic>? customData;

  const UpdateSearchData({
    required this.platform,
    required this.sources,
    required this.localVersion,
    required this.displayTarget,
    required this.appName,
    required this.appPackageName,
    required this.appStatus,
    required this.locale,
    required this.currentDate,
    required this.localReleaseDate,
    required this.updateReleaseDate,
    required this.segmentationPointer,
    required this.rolloutPointer,
    required this.customData,
  });

  UpdateSearchData copyWith({
    UpdatePlatform? platform,
    List<UpdateSource>? sources,
    Version? localVersion,
    UpdateViewTarget? displayTarget,
    UpdateLocale? locale,
    String? appName,
    String? appPackageName,
    AppStatus? appStatus,
    DateTime? currentDate,
    DateTime? localReleaseDate,
    DateTime? updateReleaseDate,
    double? segmentationPointer,
    double? rolloutPointer,
    Map<String, dynamic>? customData,
  }) =>
      UpdateSearchData(
        platform: platform ?? this.platform,
        sources: sources ?? this.sources,
        localVersion: localVersion ?? this.localVersion,
        displayTarget: displayTarget ?? this.displayTarget,
        appName: appName ?? this.appName,
        appPackageName: appPackageName ?? this.appPackageName,
        locale: locale ?? this.locale,
        appStatus: appStatus ?? this.appStatus,
        currentDate: currentDate ?? this.currentDate,
        localReleaseDate: localReleaseDate ?? this.localReleaseDate,
        updateReleaseDate: updateReleaseDate ?? this.updateReleaseDate,
        segmentationPointer: segmentationPointer ?? this.segmentationPointer,
        rolloutPointer: rolloutPointer ?? this.rolloutPointer,
        customData: Mergeable.mergeCustomData(this.customData, customData),
      );
}
