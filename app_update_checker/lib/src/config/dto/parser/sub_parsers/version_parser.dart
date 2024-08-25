// ignore_for_file: parameter_assignments

part of '../checker_config_dto_parser.dart';

class _VersionParser {
  final bool isDebug;

  const _VersionParser({required this.isDebug});

  Version? parse(
    // ignore: avoid-dynamic
    dynamic version, {
    required bool isStrict,
  }) {
    if (version is! String?) {
      if (isDebug) throw const DtoParserException();
      version = null;
    }
    if (version == null) {
      if (isStrict) throw const DtoParserException();

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
