// ignore_for_file: parameter_assignments

import 'package:pub_semver/pub_semver.dart';

import '../parse_config_exeption.dart';

class VersionParser {
  const VersionParser();

  Version? parse(
    Object? version,
  ) {
    if (version == null) return null;

    if (version is! String) {
      throw ParseConfigException.wrongType(
        rightType: String,
        wrongType: version.runtimeType,
        parserType: VersionParser,
        configs: [version],
      );
    }

    return Version.parse(version);
  }
}
