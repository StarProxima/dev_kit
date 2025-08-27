import 'package:pub_semver/pub_semver.dart';

import '../../entities/app_status.dart';
import '../../entities/update_locale.dart';
import '../../entities/update_platform.dart';
import '../../entities/update_source.dart';
import '../../entities/update_view_target.dart';
import '../../utils/mergeable.dart';

class UpdateSearchConfig {
  final List<UpdateSource>? sources;
  final UpdateViewTarget? displayTarget;
  final UpdateLocale? locale;

  /// Null for search in app_settings_rules.
  final AppStatus? appStatus;

  /// Default [UpdatePlatform.current].
  final UpdatePlatform? platform;

  /// App version, uses for compare with rule version.
  final Version? localVersion;

  /// Uses for calculate rule date and delay compliance.
  final DateTime? currentDate;
  final DateTime? localReleaseDate;
  final DateTime? updateReleaseDate;

  /// From 0.0 to 1.0, uses for calculate user segmentation compliance.
  final double? segmentationPointer;

  /// From 0.0 to 1.0, uses for calculate user rollout compliance.
  final double? rolloutPointer;

  /// Not used for search, but used for store app data and interpolation.
  final String? appName;
  final String? appPackageName;

  /// Custom data for search, checks for matches in the customData in rule.
  final Map<String, dynamic>? customData;

  const UpdateSearchConfig({
    this.platform,
    this.sources,
    this.localVersion,
    this.displayTarget,
    this.locale,
    this.currentDate,
    this.localReleaseDate,
    this.updateReleaseDate,
    this.appStatus,
    this.segmentationPointer,
    this.rolloutPointer,
    this.appName,
    this.appPackageName,
    this.customData,
  });

  UpdateSearchConfig copyWith({
    UpdatePlatform? platform,
    List<UpdateSource>? sources,
    Version? localVersion,
    UpdateViewTarget? displayTarget,
    UpdateLocale? locale,
    DateTime? currentDate,
    DateTime? localReleaseDate,
    DateTime? updateReleaseDate,
    AppStatus? appStatus,
    double? segmentationPointer,
    double? rolloutPointer,
    String? appName,
    String? appPackageName,
    Map<String, dynamic>? customData,
  }) =>
      UpdateSearchConfig(
        platform: platform ?? this.platform,
        sources: sources ?? this.sources,
        localVersion: localVersion ?? this.localVersion,
        displayTarget: displayTarget ?? this.displayTarget,
        locale: locale ?? this.locale,
        currentDate: currentDate ?? this.currentDate,
        localReleaseDate: localReleaseDate ?? this.localReleaseDate,
        updateReleaseDate: updateReleaseDate ?? this.updateReleaseDate,
        appStatus: appStatus ?? this.appStatus,
        segmentationPointer: segmentationPointer ?? this.segmentationPointer,
        rolloutPointer: rolloutPointer ?? this.rolloutPointer,
        appName: appName ?? this.appName,
        appPackageName: appPackageName ?? this.appPackageName,
        customData: Mergeable.mergeCustomData(this.customData, customData),
      );
}
