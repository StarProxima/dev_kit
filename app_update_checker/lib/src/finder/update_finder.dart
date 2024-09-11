// ignore_for_file: avoid-unnecessary-reassignment, avoid-nested-switches, prefer-correct-identifier-length

import '../localizer/models/release.dart';
import '../localizer/models/update_config.dart';
import '../shared/release_status.dart';
import '../shared/update_platform.dart';
import '../shared/version.dart';

class UpdateFinder {
  final Version appVersion;
  final UpdatePlatform platform;

  const UpdateFinder({
    required this.appVersion,
    required this.platform,
  });

  Release? findAvailableRelease(UpdateConfig config) {
    final releases = config.releases;

    // Sorted in descending order
    releases.sort((a, b) => -a.version.compareTo(b.version));

    Release? currentRelease;
    Release? latestRelease;
    ReleaseStatus latestReleaseStatus = ReleaseStatus.active;

    releasesLoop:
    for (final release in releases) {
      if (release.version < appVersion) break;

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
          latestRelease ??= release;

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
