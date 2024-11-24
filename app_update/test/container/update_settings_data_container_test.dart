// ignore_for_file: avoid-long-functions, avoid-missing-enum-constant-in-map

import 'package:app_update/src/linker/models/release_settings_data.dart';
import 'package:app_update/src/linker/models/update_settings_data_container.dart';
import 'package:app_update/src/shared/update_alert_type.dart';
import 'package:app_update/src/shared/version_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateSettingsDataContainer', () {
    const container = UpdateSettingsDataContainer({
      UpdateAlertTypeBase.base: {
        VersionStatusBase.base: UpdateSettingsData(
          canSkipRelease: true,
          reminderPeriod: Duration(hours: 48),
          customData: {'key1': 'value1'},
        ),
        VersionStatusBase.deprecated: UpdateSettingsData(
          canPostponeRelease: false,
          customData: {'key2': 'wow'},
        ),
      },
      UpdateAlertTypeBase.dialog: {
        VersionStatusBase.base: UpdateSettingsData(
          canPostponeRelease: true,
        ),
        VersionStatusBase.unsupported: UpdateSettingsData(
          releaseDelay: Duration(hours: 24),
          customData: {'key1': 'value2'},
        ),
      },
    });

    test('returns specific data for type and status', () {
      final result = container.getByBase(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.unsupported,
      );

      expect(result, isNotNull);
      expect(result?.canSkipRelease, true);
      expect(result?.canPostponeRelease, true);
      expect(result?.releaseDelay, const Duration(hours: 24));
      expect(result?.customData, {'key1': 'value2'});
    });

    test('merges base and type-specific data', () {
      final result = container.getByBase(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.base,
      );

      expect(result, isNotNull);
      expect(result?.canSkipRelease, true);
      expect(result?.canPostponeRelease, true);
      expect(result?.releaseDelay, isNull);
      expect(result?.customData, {'key1': 'value1'});
    });

    test('returns base data when no type-specific data available', () {
      final result = container.getByBase(
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.updatable,
      );

      expect(result, isNotNull);
      expect(result?.canSkipRelease, true);
      expect(result?.canPostponeRelease, true);
      expect(result?.reminderPeriod, const Duration(hours: 48));
      expect(result?.customData, {'key1': 'value1'});
    });

    test('returns null when no data available for type and status', () {
      final result = container.getByBase(
        type: UpdateAlertTypeBase.card,
        status: VersionStatusBase.updatable,
      );

      expect(result, isNotNull);
      expect(result?.canSkipRelease, true);
      expect(result?.canPostponeRelease, isNull);
      expect(result?.reminderPeriod, const Duration(hours: 48));
      expect(result?.customData, {'key1': 'value1'});
    });

    test('correctly merges customData from all levels', () {
      final result = container.getByBase(
        type: UpdateAlertTypeBase.card,
        status: VersionStatusBase.deprecated,
      );

      expect(result, isNotNull);
      expect(result?.canSkipRelease, true);
      expect(result?.canPostponeRelease, false);
      expect(result?.reminderPeriod, const Duration(hours: 48));
      expect(result?.customData, {'key1': 'value1', 'key2': 'wow'});
    });
  });
}
