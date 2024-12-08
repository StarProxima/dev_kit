// ignore_for_file: avoid-long-functions, prefer-moving-to-variable

import 'dart:io';

import 'package:app_update/src/controller/update_controller.dart';
import 'package:app_update/src/fetcher/update_config_fetcher.dart';
import 'package:app_update/src/shared/update_platform.dart';
import 'package:app_update/src/sources/sources.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Sources by platform', () {
    final updateConfigFetcher = UpdateConfigFetcher.byFile(
      file: File(
        '${Directory.current.path}\\test\\e2e\\update_controller_full_flow\\update_controller_full_flow_config.yaml',
      ),
    );

    PackageInfo.setMockInitialValues(
      appName: 'appName',
      packageName: 'packageName',
      version: '1.0.0',
      buildNumber: 'buildNumber',
      buildSignature: 'buildSignature',
    );
    SharedPreferences.setMockInitialValues({});

    test(
      'Get all releases for Android',
      () async {
        final controller = UpdateController(
          updateConfigFetcher: updateConfigFetcher,
          targetPlatform: UpdatePlatform.android,
        );

        final result = await controller.findAllAvailableUpdates();

        // TODO тесты на release.appUpdateStatus и на updateConfig
        expect(result.length, 2);
        expect(result.firstOrNull?.release.source.type, Sources.huaweiAppGallery);
        expect(result.lastOrNull?.release.source.name, 'gitHub');
        expect(result.firstOrNull?.release.version, Version(1, 0, 4));
        expect(result.lastOrNull?.release.version, Version(1, 0, 4));
      },
    );

    test(
      'Get all releases for Windows',
      () async {
        final controller = UpdateController(
          updateConfigFetcher: updateConfigFetcher,
          targetPlatform: UpdatePlatform.windows,
        );

        final result = await controller.findAllAvailableUpdates();

        expect(result.length, 1);
        expect(result.firstOrNull?.release.source.name, 'gitHub');
        expect(result.firstOrNull?.release.version, Version(1, 0, 5));
      },
    );

    test(
      'Get all releases for Ios',
      () async {
        final controller = UpdateController(
          updateConfigFetcher: updateConfigFetcher,
          targetPlatform: UpdatePlatform.ios,
        );

        final result = await controller.findAllAvailableUpdates();

        expect(result.length, 1);
        expect(result.firstOrNull?.release.source.type, Sources.appStore);
        expect(result.firstOrNull?.release.version, Version(1, 0, 4));
      },
    );

    test(
      'Get all releases for Linux',
      () async {
        final controller = UpdateController(
          updateConfigFetcher: updateConfigFetcher,
          targetPlatform: UpdatePlatform.linux,
        );

        final result = await controller.findAllAvailableUpdates();

        expect(result.length, 1);
        expect(result.firstOrNull?.release.source.name, 'gitHub');
        expect(result.firstOrNull?.release.version, Version(1, 0, 1));
      },
    );
  });
}
