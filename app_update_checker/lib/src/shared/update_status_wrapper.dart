import '../linker/models/release_settings_data.dart';
import '../parser/models/release_settings_config.dart';
import 'update_alert_type.dart';
import 'update_status.dart';

class UpdateSettingsConfig {
  final Map<String, Map<String, ReleaseSettingsConfig?>> _value;

  const UpdateSettingsConfig(this._value);

  ReleaseSettingsConfig? getBy({
    required UpdateAlertType type,
    required UpdateStatus status,
  }) =>
      getByRaw(type: type.name, status: status.name);

  ReleaseSettingsConfig? getByRaw({
    required String type,
    required String status,
  }) {
    final byType = _value[type] ?? _value['base'];
    final byStatus = byType?[status] ?? byType?['base'];

    return byStatus;
  }
}

class UpdateSettings with GetByMixin<ReleaseSettingsData> {
  @override
  final Map<String, Map<String, ReleaseSettingsData?>> _value;

  const UpdateSettings(this._value);
}

mixin GetByMixin<T> {
  abstract final Map<String, Map<String, T?>> _value;

  T getBy({
    required UpdateAlertType type,
    required UpdateStatus status,
  }) =>
      getByRaw(type: type.name, status: status.name);

  T getByRaw({
    required String type,
    required String status,
  }) {
    final byType = _value[type] ?? _value['base'];
    if (byType == null) throw Exception();

    final byStatus = byType[status] ?? byType['base'];
    if (byStatus == null) throw Exception();

    return byStatus;
  }
}
