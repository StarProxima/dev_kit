import 'package:pub_semver/pub_semver.dart';

class VersionsSettingsConfig {
  final List<VersionConstraint>? notSupportedVersions;
  final List<VersionConstraint>? deprecatedVersions;

  const VersionsSettingsConfig({
    required this.notSupportedVersions,
    required this.deprecatedVersions,
  });
}
