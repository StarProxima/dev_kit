// ignore_for_file: avoid-missing-enum-constant-in-map

import '../../parser/models/update_settings_config_container.dart';
import '../../shared/update_alert_type.dart';
import '../../shared/version_status.dart';
import 'release_settings_data.dart';

class UpdateSettingsDataContainer {
  final Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateSettingsData>> value;

  const UpdateSettingsDataContainer(this.value);

  static UpdateSettingsDataContainer? fromConfig(UpdateSettingsConfigContainer? config) {
    if (config == null) return null;

    return UpdateSettingsDataContainer(
      config.value.map(
        (key, value) => MapEntry(
          key,
          value.map(
            (key, value) => MapEntry(
              key,
              UpdateSettingsData.fromConfig(value),
            ),
          ),
        ),
      ),
    );
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
