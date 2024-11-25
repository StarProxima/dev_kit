// ignore_for_file: avoid-accessing-other-classes-private-members, avoid-unnecessary-getter, avoid-collection-mutating-methods, avoid-missing-enum-constant-in-map, avoid-non-null-assertion

import '../../linker/models/release_settings_data.dart';
import '../../linker/models/update_container_storage.dart';
import '../../linker/models/update_settings_data_container.dart';
import '../../shared/update_alert_type.dart';
import '../../shared/version_status.dart';
import 'update_settings.dart';

class UpdateSettingsContainer {
  final UpdateSettingsDataContainer defaultContainer;
  final UpdateSettingsDataContainer? controllerContainer;
  final UpdateContainerStorage<UpdateSettingsDataContainer> containerStorage;

  const UpdateSettingsContainer({
    required this.defaultContainer,
    required this.controllerContainer,
    required this.containerStorage,
  });

  UpdateSettings getBy({
    required UpdateAlertType type,
    required VersionStatus status,
  }) =>
      getByBase(
        type: type.toBase(),
        status: status.toBase(),
      );

  UpdateSettings getByBase({
    required UpdateAlertTypeBase type,
    required VersionStatusBase status,
  }) {
    // Store in a map to make it more clear which specific containers are merged next
    final dataFromAllContainers = {
      'default': defaultContainer.getByBase(type: type, status: status),
      'controller': controllerContainer?.getByBase(type: type, status: status),
      'global': containerStorage.global?.getByBase(type: type, status: status),
      'globalSource': containerStorage.globalSource?.getByBase(type: type, status: status),
      'globalSourcePlatform': containerStorage.globalSourcePlatform?.getByBase(type: type, status: status),
      'release': containerStorage.release?.getByBase(type: type, status: status),
      'releaseSource': containerStorage.releaseSource?.getByBase(type: type, status: status),
      'releaseSourcePlatform': containerStorage.releaseSourcePlatform?.getByBase(type: type, status: status),
    };

    UpdateSettingsData? settingsData;

    // ignore: unused_local_variable
    for (final MapEntry(key: name, :value) in dataFromAllContainers.entries) {
      if (value == null) continue;
      settingsData = settingsData?.merge(value) ?? value;
    }

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
