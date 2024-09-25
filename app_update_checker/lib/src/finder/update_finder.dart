// ignore_for_file: avoid-unnecessary-reassignment, avoid-nested-switches, prefer-correct-identifier-length

import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localizer/models/release.dart';
import '../shared/update_platform.dart';
import '../shared/update_status.dart';
import '../sources/source.dart';

const _lastUsedSourceName = 'updateChecker_lastUsedSourceName';

class UpdateFinder {
  final Version appVersion;
  final UpdatePlatform platform;

  const UpdateFinder({
    required this.appVersion,
    required this.platform,
  });

  Map<Source, Release?> findAvailableReleasesBySource({required List<Release> releases}) {
    // в Source определено сравнение по Url
    final availableReleasesFromAllSources = <Source, Release?>{};

    for (final release in releases) {
      final releaseSource = release.targetSource;

      if (!releaseSource.platforms.contains(platform)) {
        continue;
      }

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

  Future<Release?> findAvailableRelease({
    required Map<Source, Release?> availableReleasesBySources,
    String? prioritySourceName,
  }) async {
    final sourcesWithReleases = availableReleasesBySources.keys.toList();

    // используем приоритетный стор
    if (prioritySourceName != null) {
      final prioritySourceIndex = sourcesWithReleases.indexWhere((source) => source.name == prioritySourceName);
      if (prioritySourceIndex != -1) {
        return availableReleasesBySources[sourcesWithReleases[prioritySourceIndex]];
      }
    }

    // либо получаем последний сохранённый стор
    final pref = await SharedPreferences.getInstance(); // TODO пока здесь, но чувствую, что переедет
    final lastSource = pref.get(_lastUsedSourceName);
    if (lastSource is String) {
      final lastUsedSourceIndex = sourcesWithReleases.indexWhere((source) => source.name == lastSource);
      if (lastUsedSourceIndex != -1) {
        return availableReleasesBySources[sourcesWithReleases[lastUsedSourceIndex]];
      }
    }

    // либо определяем сами откуда установлено приложение
    final sourceCheckerName = await Sources.checkAppSource();
    if (sourceCheckerName != null) {
      final sourceIndex = sourcesWithReleases.indexWhere((source) => source.name == sourceCheckerName);
      if (sourceIndex != -1) {
        return availableReleasesBySources[sourcesWithReleases[sourceIndex]];
      }
    }

    // либо мы ни в чём не уверены и потому точно возращаем null
    return null;
  }

  Future<Release?> findCurrentRelease({required List<Release> releases}) async {
    final releasesWithAppVersion = releases.where((release) => release.version == appVersion);

    if (releasesWithAppVersion.isEmpty) return null;
    if (releasesWithAppVersion.length == 1) return releasesWithAppVersion.first;

    // если не получается понять, откуда релиз, ищем словно бы доступный
    // здесь возможно так легко преобразовать список к мапе, ибо не получится встретить два релиза из одного сурса одинаковой версии
    final releasesWithAppVersionBySource =
        releasesWithAppVersion.map((release) => MapEntry(release.targetSource, release));
    return findAvailableRelease(availableReleasesBySources: Map.fromEntries(releasesWithAppVersionBySource));
  }
}
