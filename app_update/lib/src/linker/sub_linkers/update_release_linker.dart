import 'package:collection/collection.dart';

import '../../shared/mergeable.dart';
import '../../shared/models/release/release_config.dart';
import '../../shared/models/release/release_override_config.dart';
import '../../shared/models/release/update_data.dart';
import '../../shared/models/release_platrform/release_platrform_config.dart';
import '../../shared/models/release_source/release_source_config.dart';
import '../../shared/models/update_rule/update_rule_config.dart';
import '../../shared/update_entities/update_source.dart';
import '../../shared/update_entities/update_source_name.dart';
import '../../shared/update_entities/update_version_constraint.dart';

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
  /// [sources] — список источников, используеются для получения дефолтных платформ.
  /// Если [ReleaseSourceConfig.platforms] null (но не []), то платформы будет созданы
  /// из [UpdateSource.platforms] через [ReleasePlatformConfig] для каждого источника.
  ///
  /// Если источники не заданы, то обновлений нет.
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
    final finalRelease = release
        .overrideBy(
          source.releaseOverride,
          customData: source.customData,
        )
        .overrideBy(
          platform.releaseOverride,
          customData: platform.customData,
        );

    List<UpdateRuleConfig<T>>? linkRules<T>(
      List<UpdateRuleConfig<T>>? rules,
    ) =>
        rules
            ?.map(
              (rule) => _linkRule(
                rule: rule,
                release: release,
                source: source,
                platform: platform,
              ),
            )
            .toList();

    final contentRules = Mergeable.mergeRules(
      linkRules(release.contentRules),
      linkRules(source.contentRules),
      linkRules(platform.contentRules),
    );

    final settingsRules = Mergeable.mergeRules(
      linkRules(release.settingsRules),
      linkRules(source.settingsRules),
      linkRules(platform.settingsRules),
    );

    final appSettingsRules = Mergeable.mergeRules(
      linkRules(release.appSettingsRules),
      linkRules(source.appSettingsRules),
      linkRules(platform.appSettingsRules),
    );

    return UpdateData(
      version: finalRelease.version,
      date: finalRelease.date,
      sourceName: source.sourceName,
      platform: platform.platformName,
      contentRules: contentRules,
      settingsRules: settingsRules,
      appSettingsRules: appSettingsRules,
      customData: finalRelease.customData,
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

  /// Добавляет в правило источник, платформу и версию релиза.
  UpdateRuleConfig<T> _linkRule<T>({
    required UpdateRuleConfig<T> rule,
    required ReleaseConfig release,
    required ReleaseSourceConfig? source,
    required ReleasePlatformConfig? platform,
  }) {
    final finalPlatforms = source?.platforms
        ?.map((releasePlatformConfig) => releasePlatformConfig.platformName)
        .where((platformName) => platform == null || platformName == platform.platformName)
        .toList();

    final finalSource = source != null
        ? UpdateSource.custom(
            source.sourceName,
            platforms: finalPlatforms,
          )
        : null;

    final finalRule = rule.copyWith(
      versions: [UpdateVersionConstraint(release.version)],
      sources: finalSource != null ? [finalSource] : null,
    );

    return finalRule;
  }
}
