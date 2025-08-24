import 'package:pub_semver/pub_semver.dart';

import '../../mergeable.dart';
import '../../update_entities/update_platform.dart';
import '../../update_entities/update_source.dart';

class UpdateFindData {
  final UpdatePlatform platform;
  final List<UpdateSource> sources;
  final Version localVersion;
  final DateTime currentDate;

  final Map<String, dynamic>? customData;

  const UpdateFindData({
    required this.platform,
    required this.sources,
    required this.localVersion,
    required this.currentDate,
    this.customData,
  });

  UpdateFindData copyWith({
    UpdatePlatform? platform,
    List<UpdateSource>? sources,
    Version? localVersion,
    DateTime? currentDate,
    Map<String, dynamic>? customData,
  }) =>
      UpdateFindData(
        platform: platform ?? this.platform,
        sources: sources ?? this.sources,
        localVersion: localVersion ?? this.localVersion,
        currentDate: currentDate ?? this.currentDate,
        customData: Mergeable.mergeCustomData(this.customData, customData),
      );
}
