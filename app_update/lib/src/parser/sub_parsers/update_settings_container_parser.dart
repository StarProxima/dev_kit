// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../update_config_parser.dart';

class UpdateSettingsContainerParser {
  UpdateSettingsParser get _updateSettingsParser => const UpdateSettingsParser();

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

    final map = value;

    final updateSettings = <String, Map<String, UpdateSettingsConfig>>{};

    final typeNames = [...UpdateAlertType.values.map((e) => e.name), 'base'];
    final isByType = map.keys.any(typeNames.contains);

    if (!isByType) {
      final settingsByStatus = _parseByStatus(value, parseSettings: parseSettings);

      // Empty UpdateSettings
      if (settingsByStatus.isEmpty) return const UpdateSettingsConfigContainer({});

      updateSettings['base'] = settingsByStatus;

      return UpdateSettingsConfigContainer(updateSettings);
    }

    for (final type in typeNames) {
      final value = map[type];
      if (value is! Map<String, dynamic>) continue;

      final settingsByStatus = _parseByStatus(value, parseSettings: parseSettings);
      if (settingsByStatus.isEmpty) continue;

      updateSettings[type] = settingsByStatus;
    }

    return UpdateSettingsConfigContainer(updateSettings);
  }

  Map<String, UpdateSettingsConfig> _parseByStatus(
    Map<String, dynamic> map, {
    required UpdateSettingsConfig? Function(Map<String, dynamic> map) parseSettings,
  }) {
    final settingsByStatus = <String, UpdateSettingsConfig>{};

    final statusNames = [...VersionStatus.values.map((e) => e.name), 'base'];

    final isByStatus = map.keys.any(statusNames.contains);

    if (!isByStatus) {
      final settings = parseSettings(map);
      if (settings == null) return {};

      return {'base': settings};
    }

    for (final status in statusNames) {
      final value = map[status];
      if (value == null) continue;
      final settings = parseSettings(value);
      if (settings == null) continue;
      settingsByStatus[status] = settings;
    }

    return settingsByStatus;
  }
}
