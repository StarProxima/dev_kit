// ignore_for_file: avoid-non-null-assertion

import '../parser/sub_parsers/release_config/release_config.dart';
import '../parser/sub_parsers/global_source_config/global_source_config.dart';
import '../parser/models/update_settings_config_container.dart';
import '../parser/models/update_text_config_container.dart';
import '../shared/update_platform.dart';
import '../sources/release_source.dart';
import 'models/release_data.dart';
import 'models/update_container_storage.dart';
import 'models/update_settings_data_container.dart';
import 'models/update_text_data_container.dart';

class UpdateConfigLinker {
  const UpdateConfigLinker();

  List<ReleaseData> linkConfigs({
    required UpdateSettingsConfigContainer? globalSettingsConfig,
    required UpdateTextConfigContainer? globalTextConfig,
    required List<ReleaseConfig> releasesConfig,
    required List<GlobalSourceConfig>? globalSourcesConfig,
    required UpdatePlatform platform,
  }) {
    final globalSettings = UpdateSettingsDataContainer.fromConfig(globalSettingsConfig);
    final globalTexts = UpdateTextDataContainer.fromConfig(globalTextConfig);
    final globalSources = <GlobalSourceConfig?>[...?globalSourcesConfig];
    final releases = <ReleaseData>[];

    for (final releaseConfig in releasesConfig) {
      final releaseSettings = UpdateSettingsDataContainer.fromConfig(releaseConfig.settings);
      final releaseTexts = UpdateTextDataContainer.fromConfig(releaseConfig.text);

      final releaseSources = releaseConfig.sources;
      // здесь мы уже переходим к понятию поставки. Если в релизе нет ни одного указанного стора - значит релиз никуда не поставлялся
      if (releaseSources == null || releaseSources.isEmpty) continue;

      for (final releaseSource in releaseSources) {
        final name = releaseSource.name;
        if (name == null) continue;

        final globalSource =
            globalSources.firstWhere((source) => source?.name == name, orElse: () => null);
        final globalSourceSettings = UpdateSettingsDataContainer.fromConfig(globalSource?.settings);
        final globalSourceTexts = UpdateTextDataContainer.fromConfig(globalSource?.text);

        final url = releaseSource.url;
        final sourceUrl = url ?? globalSource?.url;
        if (sourceUrl == null) continue;

        final releaseSourceRelease = releaseSource.releaseOverride;
        final releaseSourceReleaseSettings = UpdateSettingsDataContainer.fromConfig(
          releaseSourceRelease?.settings,
        );
        final releaseSourceReleaseTexts = UpdateTextDataContainer.fromConfig(
          releaseSourceRelease?.text,
        );

        final releaseSourcePlatforms = releaseSource.platforms
            ?.where((e) => e.name == platform)
            .firstOrNull
            ?.sourceOverride
            ?.releaseOverride;
        final releaseSourcePlatformSettings = UpdateSettingsDataContainer.fromConfig(
          releaseSourcePlatforms?.settings,
        );
        final releaseSourcePlatformTexts = UpdateTextDataContainer.fromConfig(
          releaseSourcePlatforms?.text,
        );

        final globalSourcePlatform = globalSource?.platforms
            ?.where((e) => e.platform == platform)
            .firstOrNull
            ?.sourceOverride;
        final globalSourcePlatformSettings = UpdateSettingsDataContainer.fromConfig(
          globalSourcePlatform?.settings,
        );
        final globalSourcePlatformTexts = UpdateTextDataContainer.fromConfig(
          globalSourcePlatform?.text,
        );

        final targetSource = ReleaseSource(
          name: name,
          url: sourceUrl,
          platforms: releaseSource.platforms?.map((e) => e.name).toList() ??
              globalSource?.platforms?.map((e) => e.platform).toList(),
          customData: releaseSource.customData ?? globalSource?.customData,
        );

        // применяем релиз конкретного магазина, если есть. Уверены, что версия не нулл, так как парсер не пропустит релиз с null версией
        final version = releaseSourceRelease?.version ?? releaseConfig.version!;
        final date = releaseSourceRelease?.date ?? releaseConfig.date;
        final releaseCustomData = releaseSourceRelease?.customData ?? releaseConfig.customData;

        final settingsContainers = UpdateContainerStorage<UpdateSettingsDataContainer>(
          global: globalSettings,
          globalSource: globalSourceSettings,
          globalSourcePlatform: globalSourcePlatformSettings,
          release: releaseSettings,
          releaseSource: releaseSourceReleaseSettings,
          releaseSourcePlatform: releaseSourcePlatformSettings,
        );
        final textContainers = UpdateContainerStorage<UpdateTextDataContainer>(
          global: globalTexts,
          globalSource: globalSourceTexts,
          globalSourcePlatform: globalSourcePlatformTexts,
          release: releaseTexts,
          releaseSource: releaseSourceReleaseTexts,
          releaseSourcePlatform: releaseSourcePlatformTexts,
        );

        // итого имеем ReleaseData для каждой конкретной поставки (пары релизКонфин-СурсКонфиг) с контейнерами для настроек и текстов
        releases.add(ReleaseData(
          version: version,
          source: targetSource,
          date: date,
          textContainers: textContainers,
          settingsContainers: settingsContainers,
          customData: releaseCustomData,
        ));
      }
    }

    return releases;
  }

  List<ReleaseSource> parseSources({
    required List<GlobalSourceConfig> sourcesConfig,
  }) {
    // убираем сурсы с одинаковыми именами
    final sources = <ReleaseSource>{};
    for (final sourceConfig in sourcesConfig) {
      final name = sourceConfig.name;
      final url = sourceConfig.url;
      final platforms = sourceConfig.platforms?.map((p) => p.platform).toList();

      if (name == null || url == null) continue;

      sources.add(ReleaseSource(
        name: name,
        url: url,
        platforms: platforms,
        customData: sourceConfig.customData,
      ));
    }

    return sources.toList();
  }
}
