// ignore_for_file: avoid-long-functions, avoid-missing-enum-constant-in-map, no-equal-arguments

import 'package:app_update/src/finalizer/models/update_settings_container.dart';
import 'package:app_update/src/linker/models/release_settings_data.dart';
import 'package:app_update/src/linker/models/update_container_storage.dart';
import 'package:app_update/src/linker/models/update_settings_data_container.dart';
import 'package:app_update/src/shared/update_alert_type.dart';
import 'package:app_update/src/shared/version_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateSettingsContainer', () {
    const defaultContainer = UpdateSettingsDataContainer({
      UpdateAlertTypeBase.base: {
        VersionStatusBase.base: UpdateSettingsData.byRequired(
          canSkipRelease: true,
          canPostponeRelease: true,
          reminderPeriod: Duration(hours: 48),
          releaseDelay: Duration.zero,
          progressiveRolloutDuration: Duration.zero,
          customData: {'key1': 'default_value'},
        ),
      },
    });

    const controllerContainer = UpdateSettingsDataContainer({
      UpdateAlertTypeBase.dialog: {
        VersionStatusBase.base: UpdateSettingsData(
          canPostponeRelease: true,
        ),
        VersionStatusBase.deprecated: UpdateSettingsData(
          canSkipRelease: false,
          customData: {'key2': 'controller_override'},
        ),
      },
    });

    const globalContainer = UpdateSettingsDataContainer({
      UpdateAlertTypeBase.dialog: {
        VersionStatusBase.unsupported: UpdateSettingsData(
          releaseDelay: Duration(hours: 24),
          customData: {'key3': 'global_value'},
        ),
      },
    });

    const releaseContainer = UpdateSettingsDataContainer({
      UpdateAlertTypeBase.base: {
        VersionStatusBase.base: UpdateSettingsData(
          progressiveRolloutDuration: Duration(hours: 96),
        ),
      },
    });

    const containerStorage = UpdateContainerStorage<UpdateSettingsDataContainer>(
      global: globalContainer,
      globalSource: null,
      globalSourcePlatform: null,
      release: releaseContainer,
      releaseSource: null,
      releaseSourcePlatform: null,
    );

    const settingsContainer = UpdateSettingsContainer(
      defaultContainer: defaultContainer,
      controllerContainer: controllerContainer,
      containerStorage: containerStorage,
    );

    test(
      'returns merged data from all containers for specific type and status',
      () {
        final result = settingsContainer.getByRaw(
          type: UpdateAlertTypeBase.dialog,
          status: VersionStatusBase.unsupported,
        );

        expect(result.canSkipRelease, true);
        expect(result.canPostponeRelease, true);
        expect(result.reminderPeriod, const Duration(hours: 48));
        expect(result.releaseDelay, const Duration(hours: 24));
        expect(result.progressiveRolloutDuration, const Duration(hours: 96));
        expect(
          result.customData,
          {'key1': 'default_value', 'key3': 'global_value'},
        );
      },
    );

    test(
      'falls back to default container when no specific data is available',
      () {
        final result = settingsContainer.getByRaw(
          type: UpdateAlertTypeBase.card,
          status: VersionStatusBase.base,
        );

        expect(result.canSkipRelease, true);
        expect(result.canPostponeRelease, true);
        expect(result.reminderPeriod, const Duration(hours: 48));
        expect(result.releaseDelay, Duration.zero);
        expect(result.progressiveRolloutDuration, const Duration(hours: 96));
        expect(result.customData, {'key1': 'default_value'});
      },
    );

    test('merges data from controller and default containers', () {
      final result = settingsContainer.getByRaw(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.base,
      );

      expect(result.canSkipRelease, true);
      expect(result.canPostponeRelease, true);
      expect(result.reminderPeriod, const Duration(hours: 48));
      expect(result.releaseDelay, Duration.zero);
      expect(result.progressiveRolloutDuration, const Duration(hours: 96));
      expect(result.customData, {'key1': 'default_value'});
    });

    test('merges customData across containers', () {
      final result = settingsContainer.getByRaw(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.deprecated,
      );

      expect(result.canSkipRelease, false);
      expect(
        result.customData,
        {'key1': 'default_value', 'key2': 'controller_override'},
      );
    });

    test('throws an exception if resulting settings data has null fields', () {
      const invalidContainer = UpdateSettingsContainer(
        defaultContainer: UpdateSettingsDataContainer({
          UpdateAlertTypeBase.base: {
            VersionStatusBase.base: UpdateSettingsData(
              reminderPeriod: Duration(hours: 48),
            ),
          },
        }),
        controllerContainer: null,
        containerStorage: UpdateContainerStorage(
          global: null,
          globalSource: null,
          globalSourcePlatform: null,
          release: null,
          releaseSource: null,
          releaseSourcePlatform: null,
        ),
      );

      expect(
        () => invalidContainer.getByRaw(
          type: UpdateAlertTypeBase.base,
          status: VersionStatusBase.base,
        ),
        throwsException,
      );
    });

    test('returns release-specific data when available', () {
      final result = settingsContainer.getByRaw(
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
      );

      expect(result.canSkipRelease, true);
      expect(result.progressiveRolloutDuration, const Duration(hours: 96));
      expect(result.customData, {'key1': 'default_value'});
    });
  });
}
