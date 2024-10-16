// ignore_for_file: avoid-accessing-other-classes-private-members, avoid-unnecessary-getter, avoid-collection-mutating-methods
import '../linker/models/release_settings_data.dart';
import '../localizer/models/release_settings.dart';
import '../localizer/models/update_texts.dart';
import '../parser/models/release_settings_config.dart';
import 'app_version_status.dart';
import 'update_alert_type.dart';

// TODO тут миксин не надо бы применить?
class UpdateSettingsConfig {
  final Map<String, Map<String, ReleaseSettingsConfig>> _value;

  const UpdateSettingsConfig(this._value);

  ReleaseSettingsConfig? getBy({
    required UpdateAlertType type,
    required VersionStatus status,
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

// TODO разнести бы их по файлам отдельным
class UpdateSettingsData with GetByMixin<ReleaseSettingsData> {
  @override
  final Map<String, Map<String, ReleaseSettingsData>> _value;

  Map<String, Map<String, ReleaseSettingsData>> get value => _value;

  const UpdateSettingsData(this._value);

  factory UpdateSettingsData.fromConfig(UpdateSettingsConfig? config) {
    return UpdateSettingsData(
      config?._value.map(
            (key, value) => MapEntry(
              key,
              value.map(
                (key, value) => MapEntry(
                  key,
                  ReleaseSettingsData.fromConfig(value),
                ),
              ),
            ),
          ) ??
          {
            'base': {'base': ReleaseSettingsData.fromConfig(null)},
          },
    );
  }

  UpdateSettingsData inherit(UpdateSettingsData child) {
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

    return UpdateSettingsData(inheritedValue);
  }
}

class UpdateSettings with GetByMixin<ReleaseSettings> {
  @override
  final Map<String, Map<String, ReleaseSettings>> _value;

  const UpdateSettings(this._value);

  factory UpdateSettings.base() => const UpdateSettings({
        'base': {
          'base': ReleaseSettings.availableUpdate(
            texts: UpdateTranslations({}),
          ),
        },
      });
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
