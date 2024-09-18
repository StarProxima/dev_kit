import '../linker/models/release_settings_data.dart';
import '../parser/models/release_settings_config.dart';
import 'update_alert_type.dart';
import 'update_status.dart';

class UpdateSettingsConfig {
  final Map<String, Map<String, ReleaseSettingsConfig?>> value;

  const UpdateSettingsConfig(this.value);

  factory UpdateSettingsConfig.parse(
    Map<String, dynamic> map, {
    required ReleaseSettingsConfig? Function(Map<String, dynamic> map) parseSettings,
  }) {
    final value = <String, Map<String, ReleaseSettingsConfig>>{};

    final typeNames = [...UpdateAlertType.values.map((e) => e.name), 'base'];
    final isByType = map.keys.every(typeNames.contains);

    if (!isByType) {
      final settingsByStatus = _parseByStatus(value, parseSettings: parseSettings);

      // Empty UpdateSettings
      if (settingsByStatus.isEmpty) return UpdateSettingsConfig(value);

      return UpdateSettingsConfig({'base': settingsByStatus});
    }

    for (final type in typeNames) {
      final value = map[type];
      if (value is! Map<String, dynamic>) continue;

      final settingsByStatus = _parseByStatus(value, parseSettings: parseSettings);
      if (settingsByStatus.isEmpty) continue;

      value[type] = settingsByStatus;
    }

    return UpdateSettingsConfig(value);
  }

  ReleaseSettingsConfig? by({
    required UpdateAlertType type,
    required UpdateStatus status,
  }) =>
      byRaw(type: type.name, status: status.name);

  ReleaseSettingsConfig? byRaw({
    required String type,
    required String status,
  }) {
    final byType = value[type] ?? value['base'];
    final byStatus = byType?[status] ?? byType?['base'];

    return byStatus;
  }

  static Map<String, ReleaseSettingsConfig> _parseByStatus(
    Map<String, dynamic> map, {
    required ReleaseSettingsConfig? Function(Map<String, dynamic> map) parseSettings,
  }) {
    final settingsByStatus = <String, ReleaseSettingsConfig>{};

    final statusNames = [...UpdateStatus.values.map((e) => e.name), 'base'];

    final isByStatus = map.keys.any(statusNames.contains);

    if (!isByStatus) {
      final settings = parseSettings(map);
      if (settings == null) return {};

      return {'base': settings};
    }

    for (final status in statusNames) {
      final value = map[status];
      final settings = parseSettings(value);
      if (settings == null) continue;
      settingsByStatus[status] = settings;
    }

    return settingsByStatus;
  }
}

class UpdateSettings {
  final Map<String, Map<String, ReleaseSettingsData?>> value;

  const UpdateSettings(this.value);

  ReleaseSettingsData by({
    required UpdateAlertType type,
    required UpdateStatus status,
  }) =>
      byRaw(type: type.name, status: status.name);

  ReleaseSettingsData byRaw({
    required String type,
    required String status,
  }) {
    final byType = value[type] ?? value['base'];
    if (byType == null) throw Exception();

    final byStatus = byType[status] ?? byType['base'];
    if (byStatus == null) throw Exception();

    return byStatus;
  }
}
