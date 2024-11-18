// ignore_for_file: avoid-missing-enum-constant-in-map, no-equal-arguments

import '../linker/models/release_settings_data.dart';
import '../linker/models/update_settings_data_container.dart';
import '../shared/update_alert_type.dart';
import '../shared/version_status.dart';

class DefaultUpdateSettingsDataContainer extends UpdateSettingsDataContainer {
  static const _settings = {
    UpdateAlertTypeBase.base: {
      VersionStatusBase.base: UpdateSettingsData.byRequired(
        canSkipRelease: false,
        canPostponeRelease: true,
        reminderPeriod: Duration(hours: 36),
        releaseDelay: Duration.zero,
        progressiveRolloutDuration: Duration.zero,
        customData: null,
      ),
      VersionStatusBase.deprecated: UpdateSettingsData(
        canSkipRelease: false,
        canPostponeRelease: true,
        reminderPeriod: Duration(hours: 6),
      ),
      VersionStatusBase.unsupported: UpdateSettingsData(
        canSkipRelease: false,
        canPostponeRelease: false,
        reminderPeriod: Duration.zero,
      ),
    },
  };

  const DefaultUpdateSettingsDataContainer() : super(_settings);
}
