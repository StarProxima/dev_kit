import 'package:pub_semver/pub_semver.dart';

import '../parser/models/versions_settings_config.dart';
import '../shared/version_status.dart';

class UpdateVersionController {
  final VersionSettingsConfig? configVersionSettings;
  const UpdateVersionController(this.configVersionSettings);

  VersionStatus setStatusByVersion({required Version version}) {
    if (configVersionSettings == null) return VersionStatus.updatable;
    final unsupportedVersions = configVersionSettings?.unsupportedVersions ?? [];
    final deprecatedVersions = configVersionSettings?.deprecatedVersions ?? [];

    if (unsupportedVersions.any((constrant) => constrant.allows(version))) {
      return VersionStatus.unsupported;
    }
    if (deprecatedVersions.any((constrant) => constrant.allows(version))) {
      return VersionStatus.deprecated;
    }

    return VersionStatus.updatable;
  }
}
