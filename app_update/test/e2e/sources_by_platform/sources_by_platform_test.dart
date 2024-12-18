// ignore_for_file: avoid-long-functions, prefer-moving-to-variable

import 'dart:io';

import 'package:app_update/src/controller/update_controller.dart';
import 'package:app_update/src/fetcher/update_config_fetcher.dart';
import 'package:app_update/src/shared/update_platform.dart';
import 'package:app_update/src/shared/version_status.dart';
import 'package:app_update/src/sources/sources.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Sources by platform', () {
    final updateConfigFetcher = UpdateConfigFetcher.byFile(
      file: File(
        p.join(Directory.current.path, 'test', 'e2e', 'sources_by_platform', 'sources_by_platform_config.yaml'),
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
      'Check config releases count',
      () async {
        final controller = UpdateController(
          updateConfigFetcher: updateConfigFetcher,
          targetPlatform: UpdatePlatform.windows,
        );

        final result = await controller.findAllAvailableUpdates();
        expect(result.length, 1);
        // ignore: avoid-unsafe-collection-methods
        final releases = result.first.config.releases;
        expect(result.firstOrNull?.config.releases.length, 13);
        expect(releases.where((e) => e.source.platforms.contains(UpdatePlatform.android)).length, 8);
        expect(releases.where((e) => e.source.platforms.contains(UpdatePlatform.windows)).length, 5);
        expect(releases.where((e) => e.source.platforms.contains(UpdatePlatform.ios)).length, 4);
        expect(releases.where((e) => e.source.platforms.contains(UpdatePlatform.linux)).length, 1);
        expect(result.firstOrNull?.config.sources.length, 3);
        expect(result.firstOrNull?.config.customData?['testName'], 'e2e');
      },
    );

    test(
      'Get all releases for Android',
      () async {
        final controller = UpdateController(
          updateConfigFetcher: updateConfigFetcher,
          targetPlatform: UpdatePlatform.android,
        );

        final result = await controller.findAllAvailableUpdates();
        expect(result.length, 2);
        expect(result.firstOrNull?.release.source.type, Sources.huaweiAppGallery);
        expect(result.lastOrNull?.release.source.name, 'gitHub');
        expect(result.firstOrNull?.release.version, Version(1, 0, 4));
        expect(result.lastOrNull?.release.version, Version(1, 0, 4));
        expect(result.firstOrNull?.appVersionStatus, VersionStatus.updatable);
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
        expect(result.firstOrNull?.appVersionStatus, VersionStatus.deprecated);
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
        expect(result.firstOrNull?.appVersionStatus, VersionStatus.updatable);
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
        expect(result.firstOrNull?.appVersionStatus, VersionStatus.updatable);
      },
    );
  });
}
