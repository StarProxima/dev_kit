// ignore_for_file: avoid-accessing-other-classes-private-members, avoid-unnecessary-getter, avoid-collection-mutating-methods
import '../linker/models/release_settings_data.dart';
import '../interpolator/models/update_settings.dart';
import '../parser/models/release_settings_config.dart';
import 'version_status.dart';
import 'update_alert_type.dart';

typedef RawUpdateSettingsContainer<T> = Map<UpdateAlertTypeBase, Map<VersionStatusBase, T>>;

// TODO тут миксин не надо бы применить?
class UpdateSettingsConfigContainer {
  final RawUpdateSettingsContainer<UpdateSettingsConfig> _value;

  const UpdateSettingsConfigContainer(this._value);

  UpdateSettingsConfig? getBy({
    required UpdateAlertType type,
    required VersionStatus status,
  }) =>
      getByBase(
        type: type.toBase(),
        status: status.toBase(),
      );

  UpdateSettingsConfig? getByBase({
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
  }) {
    final byType = _value[type] ?? _value[UpdateAlertTypeBase.base];
    final byStatus = byType?[status] ?? byType?[VersionStatusBase.base];

    return byStatus;
  }
}

// TODO разнести бы их по файлам отдельным
class UpdateSettingsDataContainer with GetByMixin<UpdateSettingsData> {
  @override
  final RawUpdateSettingsContainer<UpdateSettingsData> _value;

  RawUpdateSettingsContainer<UpdateSettingsData> get value => _value;

  const UpdateSettingsDataContainer(this._value);

  factory UpdateSettingsDataContainer.fromConfig(UpdateSettingsConfigContainer? config) {
    return UpdateSettingsDataContainer(
      // ignore: avoid-missing-enum-constant-in-map
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
            // ignore: avoid-missing-enum-constant-in-map
            UpdateAlertTypeBase.base: {
              VersionStatusBase.base: UpdateSettingsData.fromConfig(null),
            },
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
  final RawUpdateSettingsContainer<UpdateSettings> _value;

  const UpdateSettingsContainer(this._value);
}

mixin GetByMixin<T> {
  abstract final RawUpdateSettingsContainer<T> _value;

  T getBy({
    required UpdateAlertType type,
    required VersionStatus status,
  }) =>
      getByRaw(
        type: type.toBase(),
        status: status.toBase(),
      );

  T getByRaw({
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
  }) {
    final byType = _value[type] ?? _value[UpdateAlertTypeBase.base];
    if (byType == null) throw Exception();

    final byStatus = byType[status] ?? byType[VersionStatusBase.base];
    if (byStatus == null) throw Exception();

    return byStatus;
  }
}
