import 'package:pub_semver/pub_semver.dart';

class VersionSettingsConfig {
  final List<VersionConstraint>? unsupportedVersions;
  final List<VersionConstraint>? deprecatedVersions;

  const VersionSettingsConfig({
    this.unsupportedVersions,
    this.deprecatedVersions,
  });

  const VersionSettingsConfig.byRequired({
    required this.unsupportedVersions,
    required this.deprecatedVersions,
  });
}
