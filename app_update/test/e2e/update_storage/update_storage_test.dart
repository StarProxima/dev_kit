// ignore_for_file: avoid-late-keyword, prefer-moving-to-variable, avoid-duplicate-test-assertions

import 'dart:io';

import 'package:app_update/src/controller/exceptions.dart';
import 'package:app_update/src/controller/update_controller.dart';
import 'package:app_update/src/fetcher/update_config_fetcher.dart';
import 'package:app_update/src/shared/update_platform.dart';
import 'package:app_update/src/sources/sources.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'update_storage_mocked.dart';

void main() {
  group('Update storage', () {
    final updateConfigFetcher = UpdateConfigFetcher.byFile(
      file: File(
        '${Directory.current.path}\\test\\e2e\\update_storage\\update_storage_config.yaml',
      ),
    );
    const targetPlatform = UpdatePlatform.android;
    PackageInfo.setMockInitialValues(
      appName: 'appName',
      packageName: 'packageName',
      version: '1.0.0',
      buildNumber: 'buildNumber',
      buildSignature: 'buildSignature',
    );
    const testDuration = Duration(hours: 1);
    SharedPreferences.setMockInitialValues({});
    late UpdateStorageMocked storage;

    setUpAll(() async => storage = UpdateStorageMocked(
          DateTime.now(),
          await SharedPreferences.getInstance(),
        ));

    setUp(() {
      storage.nowDateTime = DateTime.now();
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'Config test',
      () async {
        final controller = UpdateController(
          updateConfigFetcher: updateConfigFetcher,
          storage: storage,
          targetPlatform: targetPlatform,
          targetSourceName: Sources.huaweiAppGallery.name,
        );

        final result = await controller.findUpdate();
        final releases = result.config.releases;
        expect(releases.length, 4);
        expect(result.release.version, Version(1, 0, 4));
      },
    );

    test(
      'Reminder later',
      () async {
        final controller = UpdateController(
          updateConfigFetcher: updateConfigFetcher,
          storage: storage,
          targetPlatform: targetPlatform,
          targetSourceName: Sources.huaweiAppGallery.name,
        );

        final result = await controller.findUpdate();
        expect(result.release.version, Version(1, 0, 4));

        await controller.postponeRelease(release: result.release, postponeDuration: testDuration);
        await expectLater(controller.findUpdate, throwsA(isA<UpdatePostponedException>()));

        storage.nowDateTime = DateTime.now().add(testDuration);
        await expectLater((await controller.findUpdate()).release.version, Version(1, 0, 4));
      },
    );

    test(
      'Skip release',
      () async {
        final controller = UpdateController(
          updateConfigFetcher: updateConfigFetcher,
          storage: storage,
          targetPlatform: targetPlatform,
          targetSourceName: Sources.huaweiAppGallery.name,
        );

        final result = await controller.findUpdate();
        expect(result.release.version, Version(1, 0, 4));

        await controller.skipRelease(result.release);
        await expectLater(controller.findUpdate, throwsA(isA<UpdateSkippedException>()));

        storage.nowDateTime = DateTime.now().add(testDuration);
        await expectLater(controller.findUpdate, throwsA(isA<UpdateSkippedException>()));
      },
    );
  });
}
