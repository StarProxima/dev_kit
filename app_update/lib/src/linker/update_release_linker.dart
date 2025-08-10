import 'package:pub_semver/pub_semver.dart';

import '../shared/models/release/release_config.dart';
import '../shared/models/release/update_data.dart';
import '../shared/models/release_platrform/release_platrform_config.dart';
import '../shared/models/release_source/release_source_config.dart';
import '../shared/models/update_app_settings/update_app_settings_config.dart';
import '../shared/models/update_content/update_content_config.dart';
import '../shared/models/update_rule/update_rule_config.dart';
import '../shared/models/update_settings/update_settings_config.dart';
import '../shared/update_entities/update_platform.dart';
import '../shared/update_entities/update_source.dart';
import '../shared/update_entities/update_source_name.dart';

class UpdateReleaseLinker {
  const UpdateReleaseLinker();

  /// Преобразует все релизы в конкретные обновления с источником и платформой.
  List<UpdateData> linkAll({
    required List<ReleaseConfig> releases,
    required List<UpdateSource> sources,
  }) {
    final updates = <UpdateData>[];

    for (final release in releases) {
      updates.addAll(link(release: release, sources: sources));
    }

    return updates;
  }

  /// Преобразует релиз в конкретные обновления с источником и платформой.
  ///
  /// Если в [ReleaseSourceConfig.platforms] пусто, то платформы будет взяты
  /// из [UpdateSource.platforms] для каждого источника.
  ///
  /// Мержит все правила в приоритете:
  /// [...releaseRules, ...releaseSourceRules, ...releasePlatformRules]
  /// в общий список правил в [UpdateData].
  List<UpdateData> link({
    required ReleaseConfig release,
    required List<UpdateSource> sources,
  }) {
    final releaseSources = release.sources;
    if (releaseSources == null || releaseSources.isEmpty) return const [];

    final updates = <UpdateData>[];

    for (final releaseSource in releaseSources) {
      final sourceName = releaseSource.sourceName;
      if (sourceName == null) {
        // Н некорректный источник — пропускаем
        continue;
      }

      // Версии/дата/кастом — с приоритетом platform > source > release
      final baseVersion = release.version; // не обязаны кидать, парсер должен гарантировать
      final baseDate = release.date;
      final baseCustom = release.customData;

      final sourceOverride = releaseSource.releaseOverride;
      final sourceVersion = sourceOverride?.version ?? baseVersion;
      final sourceDate = sourceOverride?.date ?? baseDate;
      final sourceCustom = sourceOverride?.customData ?? baseCustom;

      final hasExplicitPlatforms =
          releaseSource.platforms != null && releaseSource.platforms!.isNotEmpty;

      if (hasExplicitPlatforms) {
        for (final platformConfig in releaseSource.platforms!) {
          final built = _buildUpdateData(
            release: release,
            sourceName: sourceName,
            platformConfig: platformConfig,
            inferredPlatform: null,
            inheritedVersion: sourceVersion,
            inheritedDate: sourceDate,
            inheritedCustom: sourceCustom,
          );
          if (built != null) updates.add(built);
        }
      } else {
        // Берём платформы из глобального описания источников
        final inferredPlatforms = _inferPlatformsForSource(sourceName, sources);
        for (final platform in inferredPlatforms) {
          final built = _buildUpdateData(
            release: release,
            sourceName: sourceName,
            platformConfig: null,
            inferredPlatform: platform,
            inheritedVersion: sourceVersion,
            inheritedDate: sourceDate,
            inheritedCustom: sourceCustom,
            // правил уровня платформы нет — возьмём только release + source
          );
          if (built != null) updates.add(built);
        }
      }
    }

    return updates;
  }

  List<UpdatePlatform> _inferPlatformsForSource(
    UpdateSourceName sourceName,
    List<UpdateSource> sources,
  ) {
    final matched = sources.firstWhere(
      (s) => s.name == sourceName.name,
      orElse: () => UpdateSource.any,
    );

    // Если у источника не указаны платформы, по умолчанию вернём [any]
    final platforms = matched.platforms;
    if (platforms == null || platforms.isEmpty) return const [UpdatePlatform.any];
    return platforms;
  }

  UpdateData? _buildUpdateData({
    required ReleaseConfig release,
    required UpdateSourceName sourceName,
    required ReleasePlatformConfig? platformConfig,
    required UpdatePlatform? inferredPlatform,
    required Version? inheritedVersion,
    required DateTime? inheritedDate,
    required Map<String, dynamic>? inheritedCustom,
  }) {
    // Переопределения уровня платформы
    final platformOverride = platformConfig?.releaseOverride;
    final finalVersion = platformOverride?.version ?? inheritedVersion;
    final finalDate = platformOverride?.date ?? inheritedDate;
    final finalCustom = platformOverride?.customData ?? inheritedCustom;

    // Если версия не определена — пропускаем, некорректный кейс
    if (finalVersion == null) return null;

    // Сбор правил с приоритетом: release -> source -> platform
    final contentRules = <UpdateRuleConfig<UpdateContentConfig?>>[
      ...?release.contentRules,
      ...?release.sources
              ?.firstWhere(
                (rs) => rs.sourceName?.name == sourceName.name,
                orElse: () => const ReleaseSourceConfig(),
              )
              .contentRules ??
          const [],
      ...?platformConfig?.contentRules,
    ];
    final settingsRules = <UpdateRuleConfig<UpdateSettingsConfig?>>[
      ...?release.settingsRules,
      ...?release.sources
              ?.firstWhere(
                (rs) => rs.sourceName?.name == sourceName.name,
                orElse: () => const ReleaseSourceConfig(),
              )
              .settingsRules ??
          const [],
      ...?platformConfig?.settingsRules,
    ];
    final appSettingsRules = <UpdateRuleConfig<UpdateAppSettingsConfig?>>[
      ...?release.appSettingsRules,
      ...?release.sources
              ?.firstWhere(
                (rs) => rs.sourceName?.name == sourceName.name,
                orElse: () => const ReleaseSourceConfig(),
              )
              .appSettingsRules ??
          const [],
      ...?platformConfig?.appSettingsRules,
    ];

    return UpdateData(
      version: finalVersion,
      date: finalDate,
      source: sourceName,
      platform: platformConfig?.platformName ?? inferredPlatform ?? UpdatePlatform.any,
      contentRules: contentRules.isEmpty ? null : contentRules,
      settingsRules: settingsRules.isEmpty ? null : settingsRules,
      appSettingsRules: appSettingsRules.isEmpty ? null : appSettingsRules,
      customData: finalCustom,
    );
  }
}
