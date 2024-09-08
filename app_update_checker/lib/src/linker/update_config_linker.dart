// ignore_for_file: avoid-recursive-calls

import '../config/models/release_config.dart';
import '../config/models/store_config.dart';
import '../config/models/update_config_model.dart';
import '../models/release_status.dart';
import '../models/version.dart';
import '../stores/store.dart';
import 'models/release_data.dart';
import 'models/release_settings.dart';
import 'models/update_config_data.dart';

class UpdateConfigLinker {
  const UpdateConfigLinker();

  UpdateConfigData parseConfigFromModel(UpdateConfigModel updateConfig) {
    final releaseSettings = ReleaseSettings.fromConfig(updateConfig.releaseSettings);

    final stores = _parseStore(updateConfig.stores);

    final releases = _parseReleases(
      stores: stores,
      updateConfig: updateConfig,
      releaseSettings: releaseSettings,
    );

    final customData = updateConfig.customData;

    return UpdateConfigData(
      releaseSettings: releaseSettings,
      stores: stores,
      releases: releases,
      customData: customData,
    );
  }

  List<Store> _parseStore(List<StoreConfig> storesConfig) {
    final stores = <Store>[];
    for (final storeConfig in storesConfig) {
      final name = storeConfig.name;
      final url = storeConfig.url;
      final platforms = storeConfig.platforms;

      if (url == null) {
        throw FormatException(
          // ignore: avoid-nullable-interpolation
          "Can't parse store with parameters: $name, $url, $platforms",
        );
      }
      stores.add(Store(
        name: name,
        url: url,
        platforms: platforms,
        customData: storeConfig.customData,
      ));
    }

    return stores;
  }

  List<ReleaseData> _parseReleases({
    required List<Store> stores,
    required UpdateConfigModel updateConfig,
    required ReleaseSettings releaseSettings,
  }) {
    final releases = <ReleaseData>[];

    // Версия для релиза не уникальна.
    // Может быть несколько релизов с одинаковой версией, но с разными платформами.
    // В том числе по этому они идут списком, а не мапой.
    // TODO: Подумать, как тогда реализовать ref с dfs
    //
    // Пример:
    // - version: 0.0.1
    //   title: Title 1
    // - version: 0.0.1
    //   ref_version: 0.0.1
    //   title: Title 2
    // - version: 0.0.1
    //   ref_version: 0.0.1
    //
    // Вариант 1:
    // Ищем релиз с его version == нашему refVersion, но у которого его version != его refVersion.
    // Если не нашли - ошибка (циклическая зависимость)?
    // При этом если вышли на версию, через которую уже проходили - ошибка (циклическая зависимость).
    //
    // Тут у третьего резиза должен быть Title 1, а не Title 2.
    //
    // Вариант 2:
    // Берём самый ближайший релиз с этой версией. (Сортировка не сломает ничего?)
    //
    // Тогда у третьего резиза должен быть Title 2, а не Title 1.
    //
    // TODO: Написать отдельные тесты на всю это хуету с ref
    final releaseByVersion = {
      for (final release in updateConfig.releases) release.version: release,
    };
    final releaseStraightRef = <Version, ReleaseConfig>{};
    ReleaseConfig mergedReleaseRefDFS(ReleaseConfig node) {
      if (releaseStraightRef[node.version] != null) {
        return releaseStraightRef[node.version]!;
      }

      if (node.refVersion == null || releaseByVersion[node.refVersion] == null) {
        releaseStraightRef[node.version] = node;

        return node;
      }

      final refRelease = releaseByVersion[node.refVersion]!;
      final mergedRefRelease = mergedReleaseRefDFS(refRelease);
      final inheritedRelease = node.inherit(mergedRefRelease);
      releaseStraightRef[node.version] = inheritedRelease;

      return inheritedRelease;
    }

    for (ReleaseConfig releaseConfig in updateConfig.releases) {
      final refVersion = releaseConfig.refVersion;
      if (refVersion != null) {
        releaseConfig = mergedReleaseRefDFS(releaseConfig);
      }

      final version = releaseConfig.version;
      final buildNumber = releaseConfig.buildNumber;
      final status = releaseConfig.status;
      final canIgnoreRelease = releaseConfig.canIgnoreRelease;
      final customData = releaseConfig.customData;
      final publishDateUtc = releaseConfig.publishDateUtc;
      final titleTranslations = releaseConfig.titleTranslations;
      final descriptionTranslations = releaseConfig.descriptionTranslations;
      final releaseNoteTranslations = releaseConfig.releaseNoteTranslations;
      final releaseDelay = releaseConfig.releaseDelay;
      final reminderPeriod = releaseConfig.reminderPeriod;

      final releaseStores = <Store>[];
      final storesConfig = releaseConfig.stores;
      if (storesConfig == null) {
        releaseStores.addAll(stores);
      } else {
        for (final releaseStoreConfig in storesConfig) {
          final name = releaseStoreConfig.name;
          final url = releaseStoreConfig.url;
          final platforms = releaseStoreConfig.platforms;
          final globalStore = List<Store?>.from(stores).firstWhere(
            (store) => store?.name == name,
            orElse: () => null,
          );

          final storeUrl = url ?? globalStore?.url;
          if (storeUrl == null) continue;

          releaseStores.add(Store(
            name: name,
            url: storeUrl,
            platforms: platforms ?? globalStore?.platforms,
            customData: releaseStoreConfig.customData ?? globalStore?.customData,
          ));
        }
      }

      releases.add(ReleaseData(
        version: version,
        refVersion: refVersion,
        buildNumber: buildNumber,
        status: status ?? ReleaseStatus.active,
        titleTranslations: titleTranslations ?? releaseSettings.titleTranslations,
        descriptionTranslations: descriptionTranslations ?? releaseSettings.descriptionTranslations,
        releaseNoteTranslations: releaseNoteTranslations,
        publishDateUtc: publishDateUtc,
        canIgnoreRelease: canIgnoreRelease ?? releaseSettings.canIgnoreRelease,
        reminderPeriod: reminderPeriod ?? releaseSettings.reminderPeriod,
        releaseDelay: releaseDelay ?? releaseSettings.releaseDelay,
        stores: releaseStores,
        customData: customData,
      ));
    }

    return releases;
  }
}
