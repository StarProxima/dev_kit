// ignore_for_file: avoid-missing-enum-constant-in-map

import '../../parser/models/update_settings_config_container.dart';
import '../../shared/update_alert_type.dart';
import '../../shared/version_status.dart';
import 'release_settings_data.dart';

class UpdateSettingsConfigContainer {
  final Map<UpdateAlertTypeBase, Map<VersionStatusBase, UpdateSettingsConfig>> value;

  const UpdateSettingsConfigContainer(this.value);

  static UpdateSettingsConfigContainer? fromConfig(UpdateSettingsConfigContainer? config) {
    if (config == null) return null;

    return UpdateSettingsConfigContainer(
      config.value.map(
        (key, value) => MapEntry(
          key,
          value.map(
            (key, value) => MapEntry(
              key,
              UpdateSettingsConfig.fromConfig(value),
            ),
          ),
        ),
      ),
    );
  }

  UpdateSettingsConfig? getByBase({
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
  }) {
    final combinations = [
      (UpdateAlertTypeBase.base, VersionStatusBase.base),
      (UpdateAlertTypeBase.base, status),
      (type, VersionStatusBase.base),
      (type, status),
    ];

    UpdateSettingsConfig? settingsData;

    for (final combination in combinations) {
      // ignore: avoid-positional-record-field-access
      final byCombination = value[combination.$1]?[combination.$2];
      settingsData = settingsData?.merge(byCombination) ?? byCombination ?? settingsData;
    }

    return settingsData;
  }
}
