// ignore_for_file: avoid-collection-mutating-methods, avoid-non-null-assertion

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
    final combinations = [
      (UpdateAlertTypeBase.base, VersionStatusBase.base),
      (UpdateAlertTypeBase.base, status),
      (type, VersionStatusBase.base),
      (type, status),
    ];

    UpdateSettingsData? settingsData;

    for (final combination in combinations) {
      // ignore: avoid-positional-record-field-access
      final byCombination = value[combination.$1]?[combination.$2];
      settingsData = settingsData?.inherit(byCombination) ?? byCombination ?? settingsData;
    }

    return settingsData;
  }
}

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

    if (settingsData == null) throw Exception('SettingsData has null field');

    try {
      return UpdateSettings(
        canSkipRelease: settingsData.canSkipRelease!,
        canPostponeRelease: settingsData.canPostponeRelease!,
        reminderPeriod: settingsData.reminderPeriod!,
        releaseDelay: settingsData.releaseDelay!,
        progressiveRolloutDuration: settingsData.progressiveRolloutDuration!,
        customData: settingsData.customData,
      );
    } catch (e, s) {
      Error.throwWithStackTrace(Exception('SettingsData has null field'), s);
    }
  }
}
