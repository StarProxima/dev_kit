import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import '../controller/exceptions.dart';
import '../finalizer/models/release.dart';
import '../parser/models/global_source_config.dart';
import '../parser/models/versions_settings_config.dart';
import '../shared/update_platform.dart';
import '../sources/release_source.dart';
import '../sources/sources.dart';
import '../version_controller/update_version_controller.dart';

class UpdateFinder {
  final Version appVersion;
  final UpdatePlatform platform;

  const UpdateFinder({
    required this.appVersion,
    required this.platform,
  });

  // Для каждого имеющегося сурса ставит в соответствие самый актуальный из доступных релизов.
  // Т.е. если для аппстора есть версии 1.0.0 и 1.1.0, то аппстору будет соответствовать только 1.1.0
  Map<ReleaseSource, Release> findAvailableReleasesBySource({
    required List<Release> releases,
    required List<GlobalSourceConfig> globalSourcesConfig,
    required VersionSettingsConfig? versionSettings,
  }) {
    final availableReleasesFromAllSources = <ReleaseSource, Release>{};

    for (final release in releases) {
      final releaseSource = release.source;

      if (!releaseSource.platforms.contains(platform)) continue;

      // Обновляемся только на версии, которые строго выше нынешней
      if (release.version <= appVersion) continue;

      final globalSource = globalSourcesConfig.where((e) => e.name == releaseSource.name).firstOrNull;
      final updateVersionController = UpdateVersionController.fromGlobalSource(
        versionSettingsConfig: versionSettings,
        globalSource: globalSource,
        platform: platform,
      );

      final releaseVersionStatus = updateVersionController.setStatusByVersion(version: release.version);
      // Проверяем, актуальная ли версия релиза, если нет - пропускаем
      if (!releaseVersionStatus.isUpdatable) continue;

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
  ///
  /// Если [Sources.checkAppSource] определил, откуда пришло обновление и в [availableReleasesBySources] для этого
  /// источника не доступного релиза, то функция завершится ошибкой [UpdateNotFoundException] и обновление не будет показано.
  ///
  /// Если [Sources.checkAppSource] не определил, откуда пришло обновление, метод вернёт null, то пользователь увидет
  /// экран со списком всех источников с доступными обновлениями.
  ///
  /// Если требуется для кастомных сторов поддержать возможность обновления с одного и того же источника, то
  /// можно воспользоваться [prioritySourceName].
  Future<Release?> findAvailableRelease({
    required Map<ReleaseSource, Release> availableReleasesBySources,
    required List<ReleaseSource> sources,
    String? prioritySourceName,
    String? defaultSourceName,
  }) async {
    final sourcesWithReleases = availableReleasesBySources.keys.toList();

    // Используем приоритетный стор
    if (prioritySourceName != null) {
      final prioritySource = sourcesWithReleases.firstWhereOrNull((source) => source.name == prioritySourceName);
      if (prioritySource != null) {
        return availableReleasesBySources[prioritySource];
      }
    }

    // Либо определяем сами откуда установлено приложение
    final sourceCheckerType = await Sources.checkAppSource();
    if (sourceCheckerType != null) {
      final checkedSource = sourcesWithReleases.firstWhereOrNull((source) => source.type == sourceCheckerType);
      if (checkedSource != null) {
        // Если сурс существует в конфиге, но для него нет обновления
        if (availableReleasesBySources[checkedSource] == null && sources.contains(checkedSource)) {
          return null;
        }

        return availableReleasesBySources[checkedSource];
      }
    }

    // Либо пытаемся взять из дефолтного
    if (defaultSourceName != null) {
      final defaultSource = sourcesWithReleases.firstWhereOrNull((source) => source.name == defaultSourceName);
      if (defaultSource != null) {
        return availableReleasesBySources[defaultSource];
      }
    }

    // Либо мы ни в чём не уверены и потому точно возращаем null
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
