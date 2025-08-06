// ignore_for_file: parameter_assignments

import 'package:pub_semver/pub_semver.dart';

import '../update_config_exception.dart';

class VersionConstraintParser {
  const VersionConstraintParser();

  VersionConstraint? parse(
    // ignore: avoid-dynamic
    dynamic version,
  ) {
    if (version is! String?) throw const UpdateConfigException();

    if (version == null) return null;

    try {
      return VersionConstraint.parse(version);
    } catch (e, s) {
      Error.throwWithStackTrace(const UpdateConfigException(), s);
    }
  }
}
