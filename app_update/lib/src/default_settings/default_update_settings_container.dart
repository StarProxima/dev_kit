// ignore_for_file: avoid-missing-enum-constant-in-map

import '../finalizer/models/update_settings.dart';
import '../shared/update_alert_type.dart';
import '../shared/update_settings_container.dart';
import '../shared/version_status.dart';

class DefaultUpdateSettingsContainer extends UpdateSettingsContainer {
  static const _base = UpdateSettings.base();

  static final RawUpdateSettingsContainer<UpdateSettings> _settings = {
    UpdateAlertTypeBase.base: {
      VersionStatusBase.base: _base,
      VersionStatusBase.unsupported: _base.copyWith(
        canSkipRelease: false,
        canPostponeRelease: false,
        reminderPeriod: Duration.zero,
      ),
      VersionStatusBase.deprecated: _base.copyWith(
        canSkipRelease: false,
        reminderPeriod: const Duration(hours: 6),
      ),
    },
  };

  DefaultUpdateSettingsContainer() : super(_settings);

  DefaultUpdateSettingsContainer.merge(
    RawUpdateSettingsContainer<UpdateSettings> settings,
  ) : super(
          {..._settings, ...settings},
        );

}
