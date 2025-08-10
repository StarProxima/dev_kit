// ignore_for_file: avoid-long-functions, avoid-missing-enum-constant-in-map

import 'package:app_update/src/linker/models/release_settings_data.dart';
import 'package:app_update/src/linker/models/update_settings_data_container.dart';
import 'package:app_update/src/shared/update_alert_type.dart';
import 'package:app_update/src/shared/version_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateSettingsConfigContainer', () {
    const container = UpdateSettingsConfigContainer({
      UpdateAlertTypeBase.base: {
        VersionStatusBase.base: UpdateSettingsConfig(
          canSkipRelease: true,
          reminderPeriod: Duration(hours: 48),
          customData: {'key1': 'value1'},
        ),
        VersionStatusBase.deprecated: UpdateSettingsConfig(
          canPostponeRelease: false,
          customData: {'key2': 'wow'},
        ),
      },
      UpdateAlertTypeBase.dialog: {
        VersionStatusBase.base: UpdateSettingsConfig(
          canPostponeRelease: true,
        ),
        VersionStatusBase.unsupported: UpdateSettingsConfig(
          releaseDelay: Duration(hours: 24),
          customData: {'key1': 'value2'},
        ),
      },
    });

    test('returns data for specific alert type and version status', () {
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

    test('merges data from base and specific alert type', () {
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

    test('returns base data when specific status is not defined', () {
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

    test('falls back to base data when no specific data exists for type and status', () {
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

    test('correctly merges customData from base and specific levels', () {
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
