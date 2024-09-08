// ignore_for_file: parameter_assignments

part of '../update_config_parser.dart';

class _VersionParser {
  const _VersionParser();

  Version? parse(
    // ignore: avoid-dynamic
    dynamic version, {
    required bool isStrict,
    required bool isDebug,
  }) {
    if (version is! String?) {
      if (isDebug) throw const UpdateConfigException();
      version = null;
    }
    if (version == null) {
      if (isStrict) throw const UpdateConfigException();

      return null;
    }

    try {
      return Version.parse(version);
    } catch (e) {
      if (isDebug) rethrow;

      return null;
    }
  }
}
