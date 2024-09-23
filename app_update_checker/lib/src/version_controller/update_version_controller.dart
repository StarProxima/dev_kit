// ignore_for_file: prefer-returning-conditional-expressions

import '../linker/models/release_data.dart';
import '../parser/models/versions_settings_config.dart';
import '../shared/update_status.dart';
import 'models/release_data_with_status.dart';

class UpdateVersionController {
  final VersionSettingsConfig? versionSettings;
  const UpdateVersionController(this.versionSettings);

  List<ReleaseDataWithStatus> setStatuses(List<ReleaseData> releases) {
    if (versionSettings == null) {
      return releases.map((e) => (e, UpdateStatus.available)).toList();
    }

    final unsupportedVersions = versionSettings?.unsupportedVersions ?? [];
    final deprecatedVersions = versionSettings?.deprecatedVersions ?? [];

    return releases.map((release) {
      if (unsupportedVersions.any((constrant) => constrant.allows(release.version))) {
        return (release, UpdateStatus.required);
      }
      if (deprecatedVersions.any((constrant) => constrant.allows(release.version))) {
        return (release, UpdateStatus.recommended);
      }

      return (release, UpdateStatus.available);
    }).toList();
  }
}
