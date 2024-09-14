import 'package:pub_semver/pub_semver.dart';

class VersionsSettingsConfig {
  final List<VersionConstraint>? unsupportedVersions;
  final List<VersionConstraint>? deprecatedVersions;

  const VersionsSettingsConfig({
    required this.unsupportedVersions,
    required this.deprecatedVersions,
  });
}
