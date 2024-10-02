// ignore_for_file: parameter_assignments

import 'package:pub_semver/pub_semver.dart';

import '../models/update_config_exception.dart';

class VersionParser {
  const VersionParser();

  Version? parse(
    // ignore: avoid-dynamic
    dynamic version, {
    required bool isDebug,
  }) {
    if (version is! String?) {
      if (isDebug) throw const UpdateConfigException();
      version = null;
    }
    if (version == null) return null;

    try {
      return Version.parse(version);
    } catch (e, s) {
      if (isDebug) Error.throwWithStackTrace(const UpdateConfigException(), s);

      return null;
    }
  }
}
