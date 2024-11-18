// ignore_for_file: avoid-collection-mutating-methods

import '../../parser/models/update_settings_config_container.dart';
import '../../shared/update_alert_type.dart';
import '../../shared/version_status.dart';
import 'release_settings_data.dart';

class UpdateSettingsDataContainer {
  final Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateSettingsData>> value;

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

  UpdateSettingsDataContainer merge(UpdateSettingsDataContainer child) {
    final mergedValue = {...child.value};

    for (final type in value.entries) {
      if (mergedValue.containsKey(type.key)) {
        for (final status in type.value.entries) {
          if (mergedValue[type.key]!.containsKey(status.key)) {
            final childSettings = mergedValue[type.key]![status.key]!;
            mergedValue[type.key]?[status.key] = status.value.merge(childSettings);
          } else {
            mergedValue[type.key]?[status.key] = status.value;
          }
        }
      } else {
        mergedValue[type.key] = type.value;
      }
    }

    return UpdateSettingsDataContainer(mergedValue);
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
      settingsData = settingsData?.merge(byCombination) ?? byCombination ?? settingsData;
    }

    return settingsData;
  }
}
