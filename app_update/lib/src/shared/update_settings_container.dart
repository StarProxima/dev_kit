// ignore_for_file: avoid-accessing-other-classes-private-members, avoid-unnecessary-getter, avoid-collection-mutating-methods

import 'package:flutter/widgets.dart';

import '../finalizer/models/update_settings.dart';
import '../linker/models/release_settings_data.dart';
import '../parser/models/release_settings_config.dart';
import 'update_alert_type.dart';
import 'version_status.dart';

typedef RawUpdateSettingsContainer<T> = Map<UpdateAlertTypeBase, Map<VersionStatusBase, T>>;

class UpdateSettingsConfigContainer {
  final RawUpdateSettingsContainer<UpdateSettingsConfig> value;

  const UpdateSettingsConfigContainer(this.value);

  @visibleForTesting
  UpdateSettingsConfig? getBy({
    required UpdateAlertType type,
    required VersionStatus status,
  }) =>
      getByBase(
        type: type.toBase(),
        status: status.toBase(),
      );

  @visibleForTesting
  UpdateSettingsConfig? getByBase({
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
  }) {
    final byType = value[type] ?? value[UpdateAlertTypeBase.base];
    final byStatus = byType?[status] ?? byType?[VersionStatusBase.base];

    return byStatus;
  }
}

// TODO разнести бы их по файлам отдельным
class UpdateSettingsDataContainer {
  final RawUpdateSettingsContainer<UpdateSettingsData> value;

  const UpdateSettingsDataContainer(this.value);

  factory UpdateSettingsDataContainer.fromConfig(UpdateSettingsConfigContainer? config) {
    return UpdateSettingsDataContainer(
      // ignore: avoid-missing-enum-constant-in-map
      config?.value.map(
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

  UpdateSettingsData? getByBase({
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
  }) {
    UpdateSettingsData? settingsData;

    final base = value[UpdateAlertTypeBase.base]?[VersionStatusBase.base];
    settingsData = base;

    final byStatus = value[UpdateAlertTypeBase.base]?[status];
    settingsData = settingsData?.inherit(byStatus) ?? byStatus;

    final byType = value[type]?[VersionStatusBase.base];
    settingsData = settingsData?.inherit(byType) ?? byType;

    final byTypeAndStatus = value[type]?[status];
    settingsData = settingsData?.inherit(byTypeAndStatus) ?? byTypeAndStatus;

    return settingsData;
  }
}

// class UpdateSettingsContainer {
//   final RawUpdateSettingsContainer<UpdateSettings> value;

//   const UpdateSettingsContainer(this.value);

//   UpdateSettings getBy({
//     required UpdateAlertType type,
//     required VersionStatus status,
//   }) =>
//       getByBase(
//         type: type.toBase(),
//         status: status.toBase(),
//       );

//   UpdateSettings getByBase({
//     required UpdateAlertTypeBase type,
//     required VersionStatusBase status,
//   }) {
//     final byType = value[type] ?? value[UpdateAlertTypeBase.base];
//     if (byType == null) throw Exception();

//     final byStatus =
//         byType[status] ?? byType[VersionStatusBase.base] ?? value[UpdateAlertTypeBase.base]?[VersionStatusBase.base];
//     if (byStatus == null) throw Exception();

//     return byStatus;
//   }
// }

class UpdateSettingsContainer {
  final UpdateSettingsDataContainer dataContainer;

  const UpdateSettingsContainer({
    required this.dataContainer,
  });

  UpdateSettings getBy({
    required UpdateAlertType type,
    required VersionStatus status,
  }) =>
      getByRaw(
        type: type.toBase(),
        status: status.toBase(),
      );

  UpdateSettings getByRaw({
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
  }) {
    final settingsData = dataContainer.getByBase(type: type, status: status);

    if (settingsData == null) throw 'Ти хуесос полный';

    try {
      return UpdateSettings(
        canSkipRelease: settingsData.canSkipRelease!,
        canPostponeRelease: settingsData.canPostponeRelease!,
        reminderPeriod: settingsData.reminderPeriod!,
        releaseDelay: settingsData.releaseDelay!,
        progressiveRolloutDuration: settingsData.progressiveRolloutDuration!,
        customData: {},
      );
    } catch (e, s) {
      throw Error.throwWithStackTrace('Ти хуесос полный', s);
    }
  }
}
