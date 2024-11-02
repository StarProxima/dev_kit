// ignore_for_file: avoid-recursive-calls, avoid-non-null-assertion, avoid-similar-names

import '../parser/models/release_config.dart';
import '../parser/models/source_config.dart';
import '../shared/update_status_wrapper.dart';
import '../sources/source.dart';
import 'models/release_data.dart';

// TODO: (iamgirya)
// По идее, линкер должен получать ещё сурс и платформу, чтобы всё слинковать и выдавать конкретные ReleaseData.
// Для линкера 100% нужны тесты.
//
// Как минимум, нужно проверить, что:
// 1) Глобальные сурсах наследуют и переопределяют настройки и настройки версий
// 2) Платформы в глобальных сторах наследуют и переопределяют свой сурс (с настройками и настройками версий)
// 3) Релизы наследуют и переопределяют настройки
// 4) Сурсы в релизах наследуют и переопределяют глобальный сурс и релиз (с настройками)
// 5) Платформы в сурсах релиза наследуют и переопределяют свой сурс (с релизом)
class UpdateConfigLinker {
  const UpdateConfigLinker();

  List<ReleaseData> linkConfigs({
    required UpdateSettingsConfigContainer? globalSettingsConfig,
    required List<ReleaseConfig> releasesConfig,
    required List<GlobalSourceConfig>? globalSourcesConfig,
  }) {
    UpdateSettingsDataContainer inheritedSettings = UpdateSettingsDataContainer.fromConfig(globalSettingsConfig);

    final globalSources = <GlobalSourceConfig?>[...?globalSourcesConfig];
    final releases = <ReleaseData>[];

    for (final releaseConfig in releasesConfig) {
      // мержим настройки релиза с глобальными настройками
      final updateSettings = releaseConfig.settings;
      if (updateSettings != null) {
        inheritedSettings = inheritedSettings.inherit(UpdateSettingsDataContainer.fromConfig(updateSettings));
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
          inheritedSettings = inheritedSettings.inherit(UpdateSettingsDataContainer.fromConfig(sourceSettings));
        }

        // TODO: Сурсы теперь содержать nullable поля (которые, по идее, должны быть обязательными),
        // т.к. им можно переопределять (а для этого нужна фулл nullable модель).
        // См. TODO №10
        final targetSource = Source(
          name: name,
          url: sourceUrl,
          platforms: platforms ?? globalSource?.platforms,
          customData: customData ?? globalSource?.customData,
        );

        // применяем релиз конкретного магазина, если есть. Уверены, что версия не нулл, так как парсер не пропустит релиз с null версией
        final version = sourceReleaseConfig?.version ?? releaseConfig.version!;
        final date = sourceReleaseConfig?.date ?? releaseConfig.date;
        final releaseCustomData = sourceReleaseConfig?.customData ?? releaseConfig.customData;

        // итого имеем ReleaseData для каждой конкретной поставки (пары релизКонфин-СурсКонфиг), настройки которого смержены со всеми и находятся в settings
        releases.add(ReleaseData(
          version: version,
          source: targetSource,
          date: date,
          settings: inheritedSettings,
          customData: releaseCustomData,
        ));
      }
    }

    return releases;
  }

  List<Source> parseSources({
    required List<GlobalSourceConfig> sourcesConfig,
  }) {
    // // в случае, если мы находим несколько сурсов с одинаковыми именами, то берём только сурс с самой последней версии
    // final versionBySource = <Source, Version>{};
    // for (final release in releasesData) {
    //   final source = release.targetSource;
    //   final releaseVersion = release.version;
    //   if (versionBySource.containsKey(source)) {
    //     final addedSourceVersion = versionBySource[source]!;
    //     if (addedSourceVersion < releaseVersion) {
    //       versionBySource[source] = releaseVersion;
    //     }
    //   } else {
    //     versionBySource[source] = releaseVersion;
    //   }
    // }

    final sources = <Source>[];
    for (final sourceConfig in sourcesConfig) {
      final name = sourceConfig.name;
      final url = sourceConfig.url;
      final platforms = sourceConfig.platforms;

      // См. выше
      sources.add(Source(
        name: name,
        url: url,
        platforms: platforms,
        customData: sourceConfig.customData,
      ));
    }

    return sources;
  }
}
