import 'package:pub_semver/pub_semver.dart';

class VersionSettingsConfig {
  final List<VersionConstraint>? unsupportedVersions;
  final List<VersionConstraint>? deprecatedVersions;

  const VersionSettingsConfig({
    required this.unsupportedVersions,
    required this.deprecatedVersions,
  });
}
