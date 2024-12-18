// ignore_for_file: avoid-long-functions, prefer-moving-to-variable, avoid-missing-enum-constant-in-map

import 'package:app_update/src/controller/update_controller.dart';
import 'package:app_update/src/linker/models/release_settings_data.dart';
import 'package:app_update/src/linker/models/update_settings_data_container.dart';
import 'package:app_update/src/linker/models/update_text_data.dart';
import 'package:app_update/src/linker/models/update_text_data_container.dart';
import 'package:app_update/src/shared/update_alert_type.dart';
import 'package:app_update/src/shared/update_platform.dart';
import 'package:app_update/src/shared/version_status.dart';
import 'package:app_update/src/sources/sources.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Fetcher by sources', () {
    WidgetsFlutterBinding.ensureInitialized();
    PackageInfo.setMockInitialValues(
      appName: 'com.nullexp.cube_system',
      packageName: 'com.nullexp.cubeSystem',
      version: '1.0.0',
      buildNumber: '',
      buildSignature: '',
    );
    SharedPreferences.setMockInitialValues({});

    test(
      'Fetch test app for Android',
      () async {
        final controller = UpdateController(
          targetPlatform: UpdatePlatform.android,
          targetSourceName: Sources.googlePlay.name,
        );

        final result = await controller.findUpdate();

        expect(result.release.source.type, Sources.googlePlay);
        expect(result.release.version, Version(1, 2, 1));
        // TODO убрать как получится разобраться с releaseNotes
        // expect(
        //   result.release.text.getDefault().releaseNotes,
        //   'Исправлено отображение расписания, когда оно становится доступным',
        // );
        expect(
          result.release.source.url.toString(),
          'https://play.google.com/store/apps/details?id=com.nullexp.cube_system&hl=en',
        );
      },
    );

    test(
      'Fetch test app for Ios',
      () async {
        const testReminderPeriod = Duration(days: 123);
        const testTitle = 'lolkek';
        final controller = UpdateController(
          updateSettings: const UpdateSettingsDataContainer(
            {
              UpdateAlertTypeBase.base: {
                VersionStatusBase.base: UpdateSettingsData(
                  reminderPeriod: testReminderPeriod,
                ),
              },
            },
          ),
          updateText: UpdateTextDataContainer(
            {
              const Locale('base'): {
                UpdateAlertTypeBase.base: {
                  VersionStatusBase.base: const UpdateTextData(
                    title: testTitle,
                  ),
                },
              },
            },
          ),
          targetPlatform: UpdatePlatform.ios,
          targetSourceName: Sources.appStore.name,
        );

        final result = await controller.findUpdate();

        expect(result.release.source.type, Sources.appStore);
        expect(result.release.version, Version(1, 2, 1));
        expect(
          result.release.text.getDefault().releaseNotes,
          'Исправлено отображение расписания, когда оно становится доступным',
        );
        expect(
          result.release.source.url.toString(),
          'https://apps.apple.com/en/app/%D0%BA%D1%83%D0%B1-%D1%80%D0%B0%D1%81%D0%BF%D0%B8%D1%81%D0%B0%D0%BD%D0%B8%D0%B5/id6448701011?uo=4',
        );

        expect(result.release.settings.getDefault().reminderPeriod, testReminderPeriod);
        expect(result.release.text.getDefault().title, testTitle);
      },
    );
  });
}
