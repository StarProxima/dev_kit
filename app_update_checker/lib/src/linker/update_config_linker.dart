// ignore_for_file: avoid-recursive-calls, avoid-non-null-assertion, avoid-similar-names

import '../parser/models/release_config.dart';
import '../parser/models/source_config.dart';
import '../shared/update_status_wrapper.dart';
import '../sources/source.dart';
import 'models/release_data.dart';

// TODO Новая логика линкера, надо ревью
class UpdateConfigLinker {
  const UpdateConfigLinker();

  List<ReleaseData> linkConfigs({
    required UpdateSettingsConfig? globalSettingsConfig,
    required List<ReleaseConfig> releasesConfig,
    required List<GlobalSourceConfig>? globalSourcesConfig,
  }) {
    UpdateSettingsData? inheritedSettings =
        globalSettingsConfig == null ? null : UpdateSettingsData.fromConfig(globalSettingsConfig);

    final globalSources = <GlobalSourceConfig?>[...?globalSourcesConfig];
    final releases = <ReleaseData>[];

    for (final releaseConfig in releasesConfig) {
      // мержим настройки релиза с глобальными настройками
      final releaseSettings = releaseConfig.settings;
      if (releaseSettings != null) {
        inheritedSettings = inheritedSettings?.inherit(UpdateSettingsData.fromConfig(releaseSettings));
      }

      final sourcesConfig = releaseConfig.sources;
      // здесь мы уже переходим к понятию поставки. Если в релизе нет ни одного указанного стора - значит релиз никуда не поставлялся
      if (sourcesConfig == null) continue;
      for (final releaseSourceConfig in sourcesConfig) {
        final name = releaseSourceConfig.name;
        final url = releaseSourceConfig.url;
        final platforms = releaseSourceConfig.platforms;
        final sourceReleaseConfig = releaseSourceConfig.release;
        final customData = releaseSourceConfig.customData;

        final globalSource = globalSources.firstWhere(
          (source) => source?.name == name,
          orElse: () => null,
        );
        final sourceUrl = url ?? globalSource?.url;
        if (sourceUrl == null) continue;

        // мержим настройки сурса с релизными настройками
        final sourceSettings = globalSource?.settings ?? sourceReleaseConfig?.settings;
        if (sourceSettings != null) {
          inheritedSettings = inheritedSettings?.inherit(UpdateSettingsData.fromConfig(sourceSettings));
        }

        final targetSource = Source(
          name: name,
          url: sourceUrl,
          platforms: platforms ?? globalSource?.platforms,
          customData: customData ?? globalSource?.customData,
        );

        // применяем релиз конкретного магазина, если есть
        final version = sourceReleaseConfig?.version ?? releaseConfig.version;
        final dateUtc = sourceReleaseConfig?.dateUtc ?? releaseConfig.dateUtc;
        final releaseNoteTranslations =
            sourceReleaseConfig?.releaseNoteTranslations ?? releaseConfig.releaseNoteTranslations;
        final releaseCustomData = sourceReleaseConfig?.customData ?? releaseConfig.customData;

        // итого имеем ReleaseData для каждой конкретной поставки (пары релизКонфин-СурсКонфиг), настройки которого смержены со всеми и находятся в settings
        releases.add(ReleaseData(
          version: version,
          targetSource: targetSource,
          releaseNoteTranslations: releaseNoteTranslations,
          dateUtc: dateUtc,
          settings: inheritedSettings,
          customData: releaseCustomData,
        ));
      }
    }

    return releases;
  }

  // List<Source> _parseSources(List<GlobalSourceConfig> sourcesConfig) {
  //   final sources = <Source>[];
  //   for (final sourceConfig in sourcesConfig) {
  //     final name = sourceConfig.name;
  //     final url = sourceConfig.url;
  //     final platforms = sourceConfig.platforms;
  //     final settings = UpdateSettingsData.fromConfig(sourceConfig.settings);

  //     sources.add(Source(
  //       name: name,
  //       url: url,
  //       platforms: platforms,
  //       settings: settings,
  //       customData: sourceConfig.customData,
  //     ));
  //   }

  //   return sources;
  // }

  // List<ReleaseData> _parseReleases({
  //   required List<GlobalSourceConfig> sources,
  //   required List<ReleaseConfig> releasesConfig,
  //   required UpdateSettingsData? releaseSettings,
  // }) {

  // }
}
