// ignore_for_file: avoid-missing-enum-constant-in-map, no-equal-arguments

import '../linker/models/release_settings_data.dart';
import '../linker/models/update_settings_data_container.dart';
import '../shared/update_alert_type.dart';
import '../shared/version_status.dart';

class DefaultUpdateSettingsConfigContainer extends UpdateSettingsConfigContainer {
  static const _settings = {
    UpdateAlertTypeBase.base: {
      VersionStatusBase.base: UpdateSettingsConfig.byRequired(
        canSkipRelease: false,
        canPostponeRelease: true,
        reminderPeriod: Duration(hours: 36),
        releaseDelay: Duration.zero,
        progressiveRolloutDuration: Duration.zero,
        customData: null,
      ),
      VersionStatusBase.deprecated: UpdateSettingsConfig(
        canSkipRelease: false,
        canPostponeRelease: true,
        reminderPeriod: Duration(hours: 6),
      ),
      VersionStatusBase.unsupported: UpdateSettingsConfig(
        canSkipRelease: false,
        canPostponeRelease: false,
        reminderPeriod: Duration.zero,
      ),
    },
  };

  const DefaultUpdateSettingsConfigContainer() : super(_settings);
}
