// ignore_for_file: prefer-returning-conditional-expressions

import 'package:pub_semver/pub_semver.dart';

import '../linker/models/release_data.dart';
import '../parser/models/versions_settings_config.dart';
import '../shared/app_version_status.dart';

class UpdateVersionController {
  final VersionSettingsConfig? versionSettings;
  const UpdateVersionController(this.versionSettings);

  List<ReleaseData> filterAvailableReleaseData(List<ReleaseData> releases) {
    return releases.where((release) => setStatusByVersion(release.version) == AppVersionStatus.outdated).toList();
  }

  AppVersionStatus setStatusByVersion(Version appVersion) {
    if (versionSettings == null) return AppVersionStatus.outdated;
    final unsupportedVersions = versionSettings?.unsupportedVersions ?? [];
    final deprecatedVersions = versionSettings?.deprecatedVersions ?? [];

    if (unsupportedVersions.any((constrant) => constrant.allows(appVersion))) {
      return AppVersionStatus.unsupported;
    }
    if (deprecatedVersions.any((constrant) => constrant.allows(appVersion))) {
      return AppVersionStatus.deprecated;
    }

    return AppVersionStatus.outdated;
  }
}
