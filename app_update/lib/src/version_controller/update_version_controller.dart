import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import '../parser/models/source_config.dart';
import '../parser/models/versions_settings_config.dart';
import '../shared/update_platform.dart';
import '../shared/version_status.dart';

class UpdateVersionController {
  final VersionSettingsConfig? configVersionSettings;
  UpdateVersionController.fromGlobalSource({
    VersionSettingsConfig? versionSettingsConfig,
    GlobalSourceConfig? globalSource,
    UpdatePlatform? platform,
  }) : configVersionSettings = versionSettingsConfig
            .merge(globalSource?.versionSettings)
            .merge(globalSource?.platforms?.firstWhereOrNull((e) => e.platform == platform)?.source?.versionSettings);

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
