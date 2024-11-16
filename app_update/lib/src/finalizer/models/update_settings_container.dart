// ignore_for_file: avoid-accessing-other-classes-private-members, avoid-unnecessary-getter, avoid-collection-mutating-methods, avoid-missing-enum-constant-in-map, avoid-non-null-assertion

import '../../linker/models/update_settings_data_container.dart';
import '../../shared/update_alert_type.dart';
import '../../shared/version_status.dart';
import 'update_settings.dart';

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
