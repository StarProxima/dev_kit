// ignore_for_file: parameter_assignments

import 'package:pub_semver/pub_semver.dart';

import '../update_config_exception.dart';

class VersionConstraintParser {
  const VersionConstraintParser();

  VersionConstraint? parse(
    // ignore: avoid-dynamic
    dynamic version,
  ) {
    if (version == null) return null;

    if (version is! String) throw const UpdateConfigException();

    return VersionConstraint.parse(version);
  }
}
