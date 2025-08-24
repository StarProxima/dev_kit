import 'package:pub_semver/pub_semver.dart';

import '../../mergeable.dart';

class ReleaseOverrideConfig {
  final Version? version;
  final DateTime? date;
  final Map<String, dynamic>? customData;

  const ReleaseOverrideConfig({
    this.version,
    this.date,
    this.customData,
  });

  const ReleaseOverrideConfig.byRequired({
    required this.version,
    required this.date,
    required this.customData,
  });

  ReleaseOverrideConfig copyWith({
    Version? version,
    DateTime? date,
    Map<String, dynamic>? customData,
  }) =>
      ReleaseOverrideConfig(
        version: version ?? this.version,
        date: date ?? this.date,
        customData: Mergeable.mergeCustomData(
          this.customData,
          customData,
        ),
      );
}
