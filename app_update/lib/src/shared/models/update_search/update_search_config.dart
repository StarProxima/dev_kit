import 'package:pub_semver/pub_semver.dart';

import '../../update_entities/app_status.dart';
import '../../update_entities/update_locale.dart';
import '../../update_entities/update_platform.dart';
import '../../update_entities/update_source.dart';
import '../../update_entities/update_view_target.dart';

class UpdateSearchConfig {
  /// Default [UpdatePlatform.current].
  final UpdatePlatform? platform;

  final List<UpdateSource>? sources;
  final Version? localVersion;
  final UpdateViewTarget? displayTarget;
  final UpdateLocale? locale;

  /// Uses for calculate rule date and delay compliance.
  final DateTime? currentDate;
  final DateTime? localReleaseDate;
  final DateTime? updateReleaseDate;

  /// Null for search in app_settings_rules.
  final AppStatus? appStatus;

  /// From 0.0 to 1.0, uses for calculate user segmentation compliance.
  final double? segmentationPointer;

  /// From 0.0 to 1.0, uses for calculate user rollout compliance.
  final double? rolloutPointer;

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
    this.customData,
  });
}
