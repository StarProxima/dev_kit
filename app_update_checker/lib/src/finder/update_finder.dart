// ignore_for_file: avoid-unnecessary-reassignment, avoid-nested-switches, prefer-correct-identifier-length

import 'package:pub_semver/pub_semver.dart';

import '../localizer/models/release.dart';
import '../shared/update_platform.dart';
import '../shared/update_status.dart';
import '../sources/source.dart';

class UpdateFinder {
  final Version appVersion;
  final UpdatePlatform platform;

  const UpdateFinder({
    required this.appVersion,
    required this.platform,
  });

  Map<Source, Release?> findAvailableReleasesBySource(List<Release> releases) {
    // в Source определено сравнение по Url
    final availableReleasesFromAllSources = <Source, Release?>{};

    for (final release in releases) {
      final releaseSource = release.targetSource;

      if (release.status != UpdateStatus.available) {
        // если релиз не актуальный, но стор ни разу не встречался, то записываем стор
        if (!availableReleasesFromAllSources.containsKey(releaseSource)) {
          availableReleasesFromAllSources[releaseSource] = null;
        }
        continue;
      }

      final availableRelease = availableReleasesFromAllSources[releaseSource];
      if (availableRelease == null) {
        availableReleasesFromAllSources[releaseSource] = release;
      } else {
        if (availableRelease.version < release.version) {
          availableReleasesFromAllSources[releaseSource] = release;
        }
      }
    }

    return availableReleasesFromAllSources;
  }
}
