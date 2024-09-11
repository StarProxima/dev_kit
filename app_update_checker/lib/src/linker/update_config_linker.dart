// ignore_for_file: avoid-recursive-calls

import 'package:version/version.dart';

import '../parser/models/release_config.dart';
import '../parser/models/release_settings_config.dart';
import '../parser/models/store_config.dart';
import '../shared/release_status.dart';
import '../stores/store.dart';
import 'models/exceptions.dart';
import 'models/release_data.dart';
import 'models/release_settings.dart';
import 'models/update_config_data.dart';

class UpdateConfigLinker {
  const UpdateConfigLinker();

  UpdateConfigData linkConfigs({
    required ReleaseSettingsConfig releaseSettingsConfig,
    required List<ReleaseConfig> releasesConfig,
    required List<StoreConfig> storesConfig,
    required Map<String, dynamic>? customData,
  }) {
    final releaseSettings = ReleaseSettings.fromConfig(releaseSettingsConfig);

    final stores = _parseStore(storesConfig);

    final releases = _parseReleases(
      stores: stores,
      releasesConfig: releasesConfig,
      releaseSettings: releaseSettings,
    );

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
    required List<ReleaseConfig> releasesConfig,
    required ReleaseSettings releaseSettings,
  }) {
    final releases = <ReleaseData>[];

    // TODO: Написать отдельные тесты на всю это хуету с ref
    final releaseByVersion = {
      for (final release in releasesConfig) release.version: release,
    };

    final releaseStraightRef = <Version, ReleaseConfig?>{};
    ReleaseConfig mergedReleaseRefDFS(ReleaseConfig node) {
      if (releaseStraightRef.containsKey(node.version)) {
        // если мы пришли вновь в активированную вершину, значит у нас циклическая зависимость.
        if (releaseStraightRef[node.version] == null) throw const CyclicDependenceException();

        return releaseStraightRef[node.version]!;
      }

      if (node.refVersion == null || releaseByVersion[node.refVersion] == null) {
        releaseStraightRef[node.version] = node;

        return node;
      }

      final refRelease = releaseByVersion[node.refVersion]!;
      // Обозначаем, что мы зашли в вершину
      releaseStraightRef[node.version] = null;
      final mergedRefRelease = mergedReleaseRefDFS(refRelease);
      final inheritedRelease = node.inherit(mergedRefRelease);
      releaseStraightRef[node.version] = inheritedRelease;

      return inheritedRelease;
    }

    for (ReleaseConfig releaseConfig in releasesConfig) {
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
