import 'package:pub_semver/pub_semver.dart';

import '../../utils/mergeable.dart';

class ReleaseOverrideConfig {
  final Version? version;
  final DateTime? date;
  final Map<String, dynamic>? customParams;

  const ReleaseOverrideConfig({
    this.version,
    this.date,
    this.customParams,
  });

  const ReleaseOverrideConfig.byRequired({
    required this.version,
    required this.date,
    required this.customParams,
  });

  ReleaseOverrideConfig copyWith({
    Version? version,
    DateTime? date,
    Map<String, dynamic>? customParams,
  }) =>
      ReleaseOverrideConfig(
        version: version ?? this.version,
        date: date ?? this.date,
        customParams: Mergeable.mergecustomParams(
          this.customParams,
          customParams,
        ),
      );
}
