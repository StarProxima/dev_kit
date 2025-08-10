import 'package:collection/collection.dart';
import 'package:pub_semver/pub_semver.dart';

import '../shared/models/release/release_config.dart';
import '../shared/models/release/release_override_config.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/release_platrform/release_platrform_config.dart';
import '../shared/models/release_source/release_source_config.dart';
import '../shared/update_entities/update_source.dart';
import '../shared/update_entities/update_source_name.dart';

class UpdateReleaseLinker {
  const UpdateReleaseLinker();

  /// Преобразует все релизы в конкретные обновления с источником и платформой.
  List<UpdateData> linkAll({
    required List<ReleaseConfig> releases,
    required List<UpdateSource> sources,
  }) {
    final allUpdates = <UpdateData>[];

    for (final release in releases) {
      final updates = link(release: release, sources: sources);
      allUpdates.addAll(updates);
    }

    return allUpdates;
  }

  /// Преобразует релиз в конкретные обновления с источником и платформой.
  ///
  /// Если [ReleaseSourceConfig.platforms] null (но не []), то платформы будет созданы
  /// из [UpdateSource.platforms] через [ReleasePlatformConfig] для каждого источника.
  ///
  /// Если источники  не заданы, то обновлений нет.
  /// Применяет [ReleaseOverrideConfig], чтобы переопределить параметры релиза.
  ///
  /// Мержит все правила в приоритете:
  /// [...releaseRules, ...releaseSourceRules, ...releasePlatformRules]
  /// в общий список правил в [UpdateData].
  List<UpdateData> link({
    required ReleaseConfig release,
    required List<UpdateSource> sources,
  }) {
    final releaseSources = release.sources ?? [];

    final updates = <UpdateData>[];

    for (final releaseSource in releaseSources) {
      final platforms = releaseSource.platforms ??
          _getPlatforms(
            sourceName: releaseSource.sourceName,
            sources: sources,
          );

      for (final platform in platforms) {
        final updateData = _createUpdateData(
          release: release,
          source: releaseSource,
          platform: platform,
        );

        updates.add(updateData);
      }
    }

    return updates;
  }

  /// Создает UpdateData для конкретной комбинации релиза, источника и платформы.
  /// Применяет переопределения.
  UpdateData _createUpdateData({
    required ReleaseConfig release,
    required ReleaseSourceConfig source,
    required ReleasePlatformConfig platform,
  }) {
    final finalRerelase = release.overrideBy(
      source: source,
      platform: platform,
    );

    final finalVersion = finalRerelase.version ?? Version.none;

    return UpdateData(
      version: finalVersion,
      date: finalRerelase.date,
      source: source.sourceName,
      platform: platform.platformName,
      contentRules: finalRerelase.contentRules,
      settingsRules: finalRerelase.settingsRules,
      appSettingsRules: finalRerelase.appSettingsRules,
      customData: finalRerelase.customData,
    );
  }

  /// Получает ReleasePlatformConfig для источника из глобальных источников.
  List<ReleasePlatformConfig> _getPlatforms({
    required UpdateSourceName sourceName,
    required List<UpdateSource> sources,
  }) {
    final platforms = sources
            .firstWhereOrNull(
              (source) => source.sourceName == sourceName,
            )
            ?.platforms
            ?.map(
              (platform) => ReleasePlatformConfig(
                platformName: platform,
              ),
            )
            .toList() ??
        [];

    return platforms;
  }
}
