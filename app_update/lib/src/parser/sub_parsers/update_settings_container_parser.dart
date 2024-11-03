// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../update_config_parser.dart';

class UpdateSettingsContainerParser {
  UpdateSettingsParser get _updateSettingsParser => const UpdateSettingsParser();
  RawContainerParser get _rawContainerParser => const RawContainerParser();

  const UpdateSettingsContainerParser();

  UpdateSettingsConfigContainer? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is! Map<String, dynamic>?) {
      throw const UpdateConfigException();
    }

    if (value == null || value.isEmpty) return null;

    // ignore: avoid-dynamic
    UpdateSettingsConfig? parseSettings(dynamic value) {
      return _updateSettingsParser.parse(value, isDebug: isDebug);
    }

    final rawContainer = _rawContainerParser.parse(value, parse: parseSettings);

    final res = rawContainer[const Locale('base')];

    if (res == null) return null;

    return UpdateSettingsConfigContainer(res);
  }
}
