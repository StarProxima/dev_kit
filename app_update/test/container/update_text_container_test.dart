// ignore_for_file: avoid-long-functions, avoid-missing-enum-constant-in-map

import 'dart:ui';

import 'package:app_update/src/finalizer/models/update_text_container.dart';
import 'package:app_update/src/linker/models/update_container_storage.dart';
import 'package:app_update/src/linker/models/update_text_data.dart';
import 'package:app_update/src/linker/models/update_text_data_container.dart';
import 'package:app_update/src/shared/update_alert_type.dart';
import 'package:app_update/src/shared/version_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UpdateTextContainer', () {
    final defaultContainer = UpdateTextDataContainer({
      const Locale('base'): {
        UpdateAlertTypeBase.base: {
          VersionStatusBase.base: const UpdateTextData.byRequired(
            title: 'Default Title',
            description: 'Default Description',
            releaseNotesTitle: 'Default Release Notes Title',
            releaseNotes: 'Default Release Notes',
            skipButton: 'Skip',
            laterButton: 'Later',
            updateButton: 'Update',
            customData: null,
          ),
        },
      },
    });

    final controllerContainer = UpdateTextDataContainer({
      const Locale('en'): {
        UpdateAlertTypeBase.base: {
          VersionStatusBase.base: const UpdateTextData(
            title: 'Controller Title',
          ),
        },
      },
    });

    final globalContainer = UpdateTextDataContainer({
      const Locale('en'): {
        UpdateAlertTypeBase.dialog: {
          VersionStatusBase.base: const UpdateTextData(
            title: 'Global Dialog Title',
            description: 'Global Dialog Description',
          ),
        },
      },
    });

    final releaseContainer = UpdateTextDataContainer({
      const Locale('en'): {
        UpdateAlertTypeBase.dialog: {
          VersionStatusBase.unsupported: const UpdateTextData(
            description: 'Unsupported Release Description',
            customData: {'key1': 'value1'},
          ),
        },
      },
    });

    final containerStorage = UpdateContainerStorage<UpdateTextDataContainer>(
      global: globalContainer,
      globalSource: null,
      globalSourcePlatform: null,
      release: releaseContainer,
      releaseSource: null,
      releaseSourcePlatform: null,
    );

    final textContainer = UpdateTextContainer(
      defaultContainer: defaultContainer,
      controllerContainer: controllerContainer,
      containerStorage: containerStorage,
      interpolate: (text) => text,
    );

    test('returns merged data from all containers', () {
      final result = textContainer.getByBase(
        locale: const Locale('en'),
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.unsupported,
      );

      expect(result.title, 'Global Dialog Title');
      expect(result.description, 'Unsupported Release Description');
      expect(result.releaseNotesTitle, 'Default Release Notes Title');
      expect(result.releaseNotes, 'Default Release Notes');
      expect(result.skipButton, 'Skip');
      expect(result.laterButton, 'Later');
      expect(result.updateButton, 'Update');
      expect(result.customData, {'key1': 'value1'});
    });

    test(
      'falls back to default container when no specific container matches',
      () {
        final result = textContainer.getByBase(
          locale: const Locale('es'),
          type: UpdateAlertTypeBase.base,
          status: VersionStatusBase.base,
        );

        expect(result.title, 'Default Title');
        expect(result.description, 'Default Description');
        expect(result.releaseNotesTitle, 'Default Release Notes Title');
        expect(result.releaseNotes, 'Default Release Notes');
        expect(result.skipButton, 'Skip');
        expect(result.laterButton, 'Later');
        expect(result.updateButton, 'Update');
      },
    );

    test('throws an exception when resulting text data has null fields', () {
      final invalidContainer = UpdateTextContainer(
        defaultContainer: UpdateTextDataContainer({
          const Locale('base'): {
            UpdateAlertTypeBase.base: {
              VersionStatusBase.base: const UpdateTextData.byRequired(
                title: null,
                description: 'Description',
                releaseNotesTitle: 'Notes Title',
                releaseNotes: 'Notes',
                skipButton: 'Skip',
                laterButton: 'Later',
                updateButton: 'Update',
                customData: null,
              ),
            },
          },
        }),
        controllerContainer: null,
        containerStorage: const UpdateContainerStorage(
          global: null,
          globalSource: null,
          globalSourcePlatform: null,
          release: null,
          releaseSource: null,
          releaseSourcePlatform: null,
        ),
        interpolate: (text) => text,
      );

      expect(
        () => invalidContainer.getByBase(
          locale: const Locale('en'),
          type: UpdateAlertTypeBase.base,
          status: VersionStatusBase.base,
        ),
        throwsException,
      );
    });

    test('merges data correctly from multiple containers', () {
      final result = textContainer.getByBase(
        locale: const Locale('en'),
        type: UpdateAlertTypeBase.base,
        status: VersionStatusBase.base,
      );

      expect(
        result.title,
        'Controller Title',
      );
      expect(
        result.description,
        'Default Description',
      );
      expect(result.releaseNotesTitle, 'Default Release Notes Title');
      expect(result.releaseNotes, 'Default Release Notes');
      expect(result.skipButton, 'Skip');
      expect(result.laterButton, 'Later');
      expect(result.updateButton, 'Update');
    });

    test('uses global container for dialog-specific data', () {
      final result = textContainer.getByBase(
        locale: const Locale('en'),
        type: UpdateAlertTypeBase.dialog,
        status: VersionStatusBase.base,
      );

      expect(result.title, 'Global Dialog Title');
      expect(result.description, 'Global Dialog Description');
      expect(result.releaseNotesTitle, 'Default Release Notes Title');
      expect(result.releaseNotes, 'Default Release Notes');
    });
  });
}
