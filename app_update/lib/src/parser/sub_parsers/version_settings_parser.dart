// ignore_for_file: avoid-dynamic, avoid-collection-mutating-methods

import 'package:pub_semver/pub_semver.dart';

import '../primitive_parsers/version_constraint_parser.dart';
import '../update_config_exception.dart';
import '../models/versions_settings_config.dart';

class VersionSettingsParser {
  VersionConstraintParser get _versionConstraintParser => const VersionConstraintParser();

  const VersionSettingsParser();

  VersionSettingsConfig? parse(
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is! Map<String, dynamic>?) {
      throw const UpdateConfigException();
    }

    if (value == null) return null;

    // unsupportedVersions
    final unsupportedVersionsValue = value.remove('unsupported_versions');

    if (unsupportedVersionsValue is! List?) {
      throw const UpdateConfigException();
    }

    final unsupportedVersions = unsupportedVersionsValue
        ?.map((e) => _versionConstraintParser.parse(
              e,
              isDebug: true,
            ))
        .whereType<VersionConstraint>()
        .toList();

    // deprecatedVersions
    final deprecatedVersionsValue = value.remove('deprecated_versions');

    if (deprecatedVersionsValue is! List?) {
      throw const UpdateConfigException();
    }

    final deprecatedVersions = deprecatedVersionsValue
        ?.map((e) => _versionConstraintParser.parse(
              e,
              isDebug: true,
            ))
        .whereType<VersionConstraint>()
        .toList();

    return VersionSettingsConfig.byRequired(
      unsupportedVersions: unsupportedVersions,
      deprecatedVersions: deprecatedVersions,
    );
  }
}
