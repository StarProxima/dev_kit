import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import '../controller/exceptions.dart';
import '../localizer/models/release.dart';
import '../shared/update_platform.dart';
import '../sources/source.dart';

class UpdateFinder {
  final Version appVersion;
  final UpdatePlatform platform;

  const UpdateFinder({
    required this.appVersion,
    required this.platform,
  });

  Map<Source, Release> findAvailableReleasesBySource({
    required List<Release> releases,
  }) {
    // в Source определено сравнение по Url
    final availableReleasesFromAllSources = <Source, Release>{};

    for (final release in releases) {
      final releaseSource = release.targetSource;

      if (!releaseSource.platforms.contains(platform)) {
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

  /// Если [Sources.checkAppSource] определил, откуда пришло обновление и в [availableReleasesBySources] для этого
  /// источника есть доступный релиз, то пользователь увидет обновление.
  /// Если [Sources.checkAppSource] определил, откуда пришло обновление и в [availableReleasesBySources] для этого
  /// источника не доступного релиза, то функция завершится ошибкой [UpdateNotFoundException] и обновление не будет показано.
  /// Если [Sources.checkAppSource] не определил, откуда пришло обновление, метод вернёт null, то пользователь увидет
  /// экран со списком всех источников с доступными обновлениями.
  /// Если требуется для кастомных сторов поддержать возможность обновления с одного и того же источника, то
  /// можно воспользоваться [prioritySourceName].
  Future<Release?> findAvailableRelease({
    required Map<Source, Release> availableReleasesBySources,
    required List<Source> sources,
    String? prioritySourceName,
  }) async {
    final sourcesWithReleases = availableReleasesBySources.keys.toList();

    // используем приоритетный стор
    if (prioritySourceName != null) {
      final prioritySource = sourcesWithReleases.firstWhereOrNull((source) => source.name == prioritySourceName);
      if (prioritySource != null) {
        return availableReleasesBySources[prioritySource];
      }
    }

    // либо определяем сами откуда установлено приложение
    final sourceCheckerType = await Sources.checkAppSource();
    if (sourceCheckerType != null) {
      final checkedSource = sourcesWithReleases.firstWhereOrNull((source) => source.sourceType == sourceCheckerType);
      if (checkedSource != null) {
        // если сурс существует в конфиге, но для него нет обновления
        if (availableReleasesBySources[checkedSource] == null && sources.contains(checkedSource)) {
          throw const UpdateNotFoundException();
        }

        return availableReleasesBySources[checkedSource];
      }
    }

    // либо мы ни в чём не уверены и потому точно возращаем null
    return null;
  }

  // Future<Release?> findCurrentRelease({required List<Release> releases}) async {
  //   final releasesWithAppVersion = releases.where((release) => release.version == appVersion);

  //   if (releasesWithAppVersion.isEmpty) return null;
  //   if (releasesWithAppVersion.length == 1) return releasesWithAppVersion.firstOrNull;

  //   // если не получается понять, откуда релиз, ищем словно бы доступный
  //   // здесь возможно так легко преобразовать список к мапе, ибо не получится встретить два релиза из одного сурса одинаковой версии
  //   final releasesWithAppVersionBySource =
  //       releasesWithAppVersion.map((release) => MapEntry(release.targetSource, release));

  //   return findAvailableRelease(availableReleasesBySources: Map.fromEntries(releasesWithAppVersionBySource));
  // }
}
