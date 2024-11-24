// ignore_for_file: avoid-long-functions, avoid-missing-enum-constant-in-map

import 'dart:ui';

import 'package:app_update/src/linker/models/update_text_data.dart';
import 'package:app_update/src/linker/models/update_text_data_container.dart';
import 'package:app_update/src/shared/update_alert_type.dart';
import 'package:app_update/src/shared/version_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateTextDataContainer', () {
    final container = UpdateTextDataContainer({
      const Locale('base'): {
        UpdateAlertTypeBase.base: {
          VersionStatusBase.base: const UpdateTextData(
            title: 'Default Update Title',
            description: 'Default description for all versions.',
            customData: {'key1': 'default_value'},
          ),
        },
      },
      const Locale('en'): {
        UpdateAlertTypeBase.base: {
          VersionStatusBase.base: const UpdateTextData(
            title: 'Update Now!',
            description: 'A new version is available.',
            customData: {'key1': 'value1'},
          ),
          VersionStatusBase.deprecated: const UpdateTextData(
            title: 'Deprecated Version',
            customData: {'key2': 'deprecated'},
          ),
        },
        UpdateAlertTypeBase.dialog: {
          VersionStatusBase.base: const UpdateTextData(
            title: 'Dialog Title',
          ),
          VersionStatusBase.unsupported: const UpdateTextData(
            description: 'This version is no longer supported.',
            customData: {'key1': 'override'},
          ),
        },
      },
      const Locale('ru'): {
        UpdateAlertTypeBase.base: {
          VersionStatusBase.base: const UpdateTextData(
            title: 'Обновите приложение!',
            description: 'Доступна новая версия.',
          ),
        },
      },
    });

    test('returns specific data for locale, type, and status', () {
      final result = container.getByBase(
        locale: const Locale('en'),
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.unsupported,
      );

      expect(result, isNotNull);
      expect(result?.title, 'Dialog Title');
      expect(result?.description, 'This version is no longer supported.');
      expect(result?.customData, {'key1': 'override'});
    });

    test('merges base data and locale-specific data', () {
      final result = container.getByBase(
        locale: const Locale('en'),
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.base,
      );

      expect(result, isNotNull);
      expect(result?.title, 'Dialog Title');
      expect(result?.description, 'A new version is available.');
      expect(result?.customData, {'key1': 'value1'});
    });

    test('returns base locale data when specific locale is not defined', () {
      final result = container.getByBase(
        locale: const Locale('es'),
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
      );

      expect(result, isNotNull);
      expect(result?.title, 'Default Update Title');
      expect(result?.description, 'Default description for all versions.');
      expect(result?.customData, {'key1': 'default_value'});
    });

    test('returns null when no data available for locale, type, and status', () {
      final result = container.getByBase(
        locale: const Locale('fr'),
        type: UpdateAlertTypeBase.card,
        status: VersionStatusBase.updatable,
      );

      expect(result, isNotNull);
      expect(result?.title, 'Default Update Title');
      expect(result?.description, 'Default description for all versions.');
      expect(result?.customData, {'key1': 'default_value'});
    });

    test('correctly merges customData from all levels', () {
      final result = container.getByBase(
        locale: const Locale('en'),
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.deprecated,
      );

      expect(result, isNotNull);
      expect(result?.title, 'Deprecated Version');
      expect(result?.description, 'A new version is available.');
      expect(result?.customData, {'key1': 'value1', 'key2': 'deprecated'});
    });

    test('returns default base locale data when specific locale is missing', () {
      final result = container.getByBase(
        locale: const Locale('es'),
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
      );

      expect(result, isNotNull);
      expect(result?.title, 'Default Update Title');
      expect(result?.description, 'Default description for all versions.');
      expect(result?.customData, {'key1': 'default_value'});
    });

    test('returns specific locale data when available', () {
      final result = container.getByBase(
        locale: const Locale('ru'),
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
      );

      expect(result, isNotNull);
      expect(result?.title, 'Обновите приложение!');
      expect(result?.description, 'Доступна новая версия.');
      expect(result?.customData, {'key1': 'default_value'});
    });

    test('merges data across locale and type levels', () {
      final result = container.getByBase(
        locale: const Locale('en'),
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.unsupported,
      );

      expect(result, isNotNull);
      expect(result?.title, 'Dialog Title');
      expect(result?.description, 'This version is no longer supported.');
      expect(result?.customData, {'key1': 'override'});
    });

    test('returns null for an empty container', () {
      const emptyContainer = UpdateTextDataContainer({});
      final result = emptyContainer.getByBase(
        locale: const Locale('en'),
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
      );

      expect(result, isNull);
    });
  });
}
