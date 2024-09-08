// ignore_for_file: avoid-unnecessary-reassignment, avoid-nested-switches, prefer-correct-identifier-length

import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../linker/models/release_data.dart';
import '../linker/models/update_config_data.dart';
import '../models/release_status.dart';
import '../models/update_platform.dart';
import '../models/version.dart';
import 'models/app_update.dart';
import 'models/release.dart';
import 'models/update_config.dart';

class UpdateBuilder {
  final Locale applocale;
  final PackageInfo packageInfo;
  final UpdatePlatform platform;

  String get _appName => packageInfo.appName;
  Version get _appVersion => Version.parse(packageInfo.version);

  const UpdateBuilder({
    required this.applocale,
    required this.packageInfo,
    required this.platform,
  });

  AppUpdate? findUpdate(UpdateConfig config) {
    final availableRelease = _findAvailableRelease(config);

    if (availableRelease == null) return null;

    return AppUpdate(
      appName: _appName,
      appVersion: _appVersion,
      appLocale: applocale,
      config: config,
      availableRelease: availableRelease,
    );
  }

  UpdateConfig localizeConfig(UpdateConfigData updateConfig) {
    return UpdateConfig(
      releaseSettings: updateConfig.releaseSettings,
      stores: updateConfig.stores,
      releases: updateConfig.releases.map(_localizeRelease).toList(),
      customData: updateConfig.customData,
    );
  }

  Release _localizeRelease(ReleaseData releaseData) {
    return Release.localizedFromReleaseData(
      releaseData: releaseData,
      locale: applocale,
      appName: _appName,
      appVersion: _appVersion,
    );
  }

  Release? _findAvailableRelease(UpdateConfig config) {
    final appVersion = _appVersion;
    final releases = config.releases;

    // Sorted in descending order
    releases.sort((a, b) => -a.version.compareTo(b.version));

    Release? currentRelease;
    Release? latestRelease;
    ReleaseStatus latestReleaseStatus = ReleaseStatus.active;

    releasesLoop:
    for (final release in releases) {
      if (release.version < appVersion) continue;

      // If there is no store with the current platform - skip release.
      if (!release.stores.any((store) => store.platforms.contains(platform))) continue;

      if (release.version == appVersion) {
        currentRelease = release;
        continue;
      }

      final releaseStatus = release.status;
      switch (releaseStatus) {
        case ReleaseStatus.broken || ReleaseStatus.deprecated:
          // If the latest release is broken or deprecated, there will be no update
          if (latestRelease == null) break releasesLoop;
          continue releasesLoop;

        case ReleaseStatus.inactive:
          continue releasesLoop;

        case ReleaseStatus.required || ReleaseStatus.recommended || ReleaseStatus.active:
          if (latestRelease != null) latestRelease = release;

          // Latest release status 1: handle releaseStatus

          // If there is at least one release newer than the current release,
          // which is required or recommended,
          // then the latest release is also required or recommended, respectively.
          switch (releaseStatus) {
            case ReleaseStatus.required:
              latestReleaseStatus = ReleaseStatus.required;

            case ReleaseStatus.recommended when !latestReleaseStatus.isRequired:
              latestReleaseStatus = ReleaseStatus.recommended;

            default:
          }
      }
    }

    // Didn't find a matching release
    if (latestRelease == null) return null;

    // Latest release status 2: handle currentReleaseStatus

    final currentReleaseStatus = currentRelease?.status;

    // If the current release is broken or deprecated,
    // the latest release will be required or recommended, respectively.
    switch (currentReleaseStatus) {
      case ReleaseStatus.broken:
        latestReleaseStatus = ReleaseStatus.required;

      case ReleaseStatus.deprecated when !latestReleaseStatus.isRequired:
        latestReleaseStatus = ReleaseStatus.recommended;

      default:
    }

    // Latest release status 3: handle requiredMinimumVersion and deprecatedBeforeVersion

    final requiredMinimumVersion = config.releaseSettings.requiredMinimumVersion;
    if (requiredMinimumVersion != null && requiredMinimumVersion > appVersion) {
      latestReleaseStatus = ReleaseStatus.required;
    }

    final deprecatedBeforeVersion = config.releaseSettings.deprecatedBeforeVersion;
    if (deprecatedBeforeVersion != null && deprecatedBeforeVersion > appVersion && !latestReleaseStatus.isRequired) {
      latestReleaseStatus = ReleaseStatus.recommended;
    }

    // Return

    latestRelease = latestRelease.copyWith(
      status: latestReleaseStatus,
    );

    return latestRelease;
  }
}
