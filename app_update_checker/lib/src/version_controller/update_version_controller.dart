// ignore_for_file: prefer-returning-conditional-expressions

import 'package:pub_semver/pub_semver.dart';

import '../linker/models/release_data.dart';
import '../parser/models/versions_settings_config.dart';
import '../shared/update_status.dart';
import 'models/release_data_with_status.dart';

class UpdateVersionController {
  final VersionSettingsConfig? versionSettings;
  const UpdateVersionController(this.versionSettings);

  List<ReleaseDataWithStatus> setStatuses(List<ReleaseData> releases) {
    return releases.map((release) => (release, setStatusByVersion(release.version))).toList();
  }

  UpdateStatus setStatusByVersion(Version appVersion) {
    if (versionSettings == null) return UpdateStatus.available;
    final unsupportedVersions = versionSettings?.unsupportedVersions ?? [];
    final deprecatedVersions = versionSettings?.deprecatedVersions ?? [];

    if (unsupportedVersions.any((constrant) => constrant.allows(appVersion))) {
      return UpdateStatus.required;
    }
    if (deprecatedVersions.any((constrant) => constrant.allows(appVersion))) {
      return UpdateStatus.recommended;
    }

    return UpdateStatus.available;
  }
}
