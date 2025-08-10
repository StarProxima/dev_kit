import 'package:pub_semver/pub_semver.dart';

import '../../update_entities/app_status.dart';
import '../../update_entities/update_locale.dart';
import '../../update_entities/update_platform.dart';
import '../../update_entities/update_source.dart';
import '../../update_entities/update_view_target.dart';

class UpdateSearchData {
  final UpdatePlatform platform;
  final List<UpdateSource> sources;
  final Version localVersion;
  final UpdateViewTarget displayTarget;
  final UpdateLocale locale;

  /// Null for search in app_status_rules.
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
    required this.appStatus,
    required this.locale,
    required this.currentDate,
    required this.localReleaseDate,
    required this.updateReleaseDate,
    required this.segmentationPointer,
    required this.rolloutPointer,
    required this.customData,
  });
}
