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

    final d = _rawContainerParser.parse(value, parse: parseSettings);

    final res = d[Locale('base')];

    if (res == null) return null;

    return UpdateSettingsConfigContainer(res);

    final map = value;

    final RawUpdateSettingsContainer<UpdateSettingsConfig> updateSettings = {};

    final typeNames = [...UpdateAlertType.values.map((e) => e.name)];
    // final typeBaseKeys = UpdateAlertTypeBase.values.map((e) => e.key);
    final statusNames = [...VersionStatus.values.map((e) => e.name)];

    final isContainsBase = map.containsKey('base');
    final isByType = map.keys.any(typeNames.contains);
    final isByStatus = map.keys.any(statusNames.contains);

    if (isByStatus || (!isByType && !isByStatus && !isContainsBase)) {
      final settingsByStatus = _parseByStatus(value, parseSettings: parseSettings);

      // Empty UpdateSettings
      if (settingsByStatus.isEmpty) return const UpdateSettingsConfigContainer({});

      updateSettings[UpdateAlertTypeBase.base] = settingsByStatus;

      return UpdateSettingsConfigContainer(updateSettings);
    }

    for (final type in UpdateAlertTypeBase.values) {
      final key = type.key;
      final value = map[key];
      if (value is! Map<String, dynamic>) continue;

      final settingsByStatus = _parseByStatus(value, parseSettings: parseSettings);
      if (settingsByStatus.isEmpty) continue;

      updateSettings[type] = settingsByStatus;
    }

    return UpdateSettingsConfigContainer(updateSettings);
  }

  Map<VersionStatusBase, UpdateSettingsConfig> _parseByStatus(
    Map<String, dynamic> map, {
    required UpdateSettingsConfig? Function(Map<String, dynamic> map) parseSettings,
  }) {
    final settingsByStatus = <VersionStatusBase, UpdateSettingsConfig>{};

    final statusBaseKeys = VersionStatusBase.values.map((e) => e.key);

    final isByStatus = map.keys.any(statusBaseKeys.contains);

    if (!isByStatus) {
      final settings = parseSettings(map);
      if (settings == null) return {};

      // ignore: avoid-missing-enum-constant-in-map
      return {VersionStatusBase.base: settings};
    }

    for (final status in VersionStatusBase.values) {
      final key = status.key;
      final value = map[key];
      if (value == null) continue;

      final settings = parseSettings(value);
      if (settings == null) continue;

      settingsByStatus[status] = settings;
    }

    return settingsByStatus;
  }
}
