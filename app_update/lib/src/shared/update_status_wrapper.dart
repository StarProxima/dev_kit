// ignore_for_file: avoid-accessing-other-classes-private-members, avoid-unnecessary-getter, avoid-collection-mutating-methods
import '../linker/models/release_settings_data.dart';
import '../localizer/models/update_settings.dart';
import '../parser/models/release_settings_config.dart';
import 'app_version_status.dart';
import 'update_alert_type.dart';

// TODO тут миксин не надо бы применить?
class UpdateSettingsConfigContainer {
  final Map<String, Map<String, UpdateSettingsConfig>> _value;

  const UpdateSettingsConfigContainer(this._value);

  UpdateSettingsConfig? getBy({
    required UpdateAlertType type,
    required VersionStatus status,
  }) =>
      getByRaw(type: type.name, status: status.name);

  UpdateSettingsConfig? getByRaw({
    required String type,
    required String status,
  }) {
    final byType = _value[type] ?? _value['base'];
    final byStatus = byType?[status] ?? byType?['base'];

    return byStatus;
  }
}

// TODO разнести бы их по файлам отдельным
class UpdateSettingsDataContainer with GetByMixin<UpdateSettingsData> {
  @override
  final Map<String, Map<String, UpdateSettingsData>> _value;

  Map<String, Map<String, UpdateSettingsData>> get value => _value;

  const UpdateSettingsDataContainer(this._value);

  factory UpdateSettingsDataContainer.fromConfig(UpdateSettingsConfigContainer? config) {
    return UpdateSettingsDataContainer(
      config?._value.map(
            (key, value) => MapEntry(
              key,
              value.map(
                (key, value) => MapEntry(
                  key,
                  UpdateSettingsData.fromConfig(value),
                ),
              ),
            ),
          ) ??
          {
            'base': {'base': UpdateSettingsData.fromConfig(null)},
          },
    );
  }

  UpdateSettingsDataContainer inherit(UpdateSettingsDataContainer child) {
    final inheritedValue = {...child.value};

    for (final type in value.entries) {
      if (inheritedValue.containsKey(type.key)) {
        for (final status in type.value.entries) {
          if (inheritedValue[type.key]!.containsKey(status.key)) {
            final childSettings = inheritedValue[type.key]![status.key]!;
            inheritedValue[type.key]?[status.key] = status.value.inherit(childSettings);
          } else {
            inheritedValue[type.key]?[status.key] = status.value;
          }
        }
      } else {
        inheritedValue[type.key] = type.value;
      }
    }

    return UpdateSettingsDataContainer(inheritedValue);
  }
}

class UpdateSettingsContainer with GetByMixin<UpdateSettings> {
  @override
  final Map<String, Map<String, UpdateSettings>> _value;

  const UpdateSettingsContainer(this._value);
}

mixin GetByMixin<T> {
  abstract final Map<String, Map<String, T>> _value;

  T getBy({
    required UpdateAlertType type,
    required VersionStatus status,
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
