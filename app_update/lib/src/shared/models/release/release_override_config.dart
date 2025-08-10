import 'package:pub_semver/pub_semver.dart';

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
}
