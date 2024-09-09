// ignore_for_file: parameter_assignments

part of '../update_config_parser.dart';

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
      if (isDebug) Error.throwWithStackTrace(UpdateConfigException(), s);

      return null;
    }
  }
}
