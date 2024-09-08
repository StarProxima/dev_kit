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

  UpdateConfigData parseConfigFromModel(UpdateConfigModel checkerConfigDTO) {
    final releaseSettings = ReleaseSettings.fromDTO(checkerConfigDTO.releaseSettings);

    final stores = _parseStore(checkerConfigDTO.stores);

    final releases = _parseReleases(
      stores: stores,
      checkerConfigDTO: checkerConfigDTO,
      releaseSettings: releaseSettings,
    );

    final customData = checkerConfigDTO.customData;

    return UpdateConfigData(
      releaseSettings: releaseSettings,
      stores: stores,
      releases: releases,
      customData: customData,
    );
  }

  List<Store> _parseStore(List<StoreConfig> storesDTO) {
    final stores = <Store>[];
    for (final storeDTO in storesDTO) {
      final name = storeDTO.name;
      final url = storeDTO.url;
      final platforms = storeDTO.platforms;

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
        customData: storeDTO.customData,
      ));
    }

    return stores;
  }

  List<ReleaseData> _parseReleases({
    required List<Store> stores,
    required UpdateConfigModel checkerConfigDTO,
    required ReleaseSettings releaseSettings,
  }) {
    final releases = <ReleaseData>[];

    final releaseByVersion = {
      for (final release in checkerConfigDTO.releases) release.version: release,
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

    for (ReleaseConfig releaseDTO in checkerConfigDTO.releases) {
      final refVersion = releaseDTO.refVersion;
      if (refVersion != null) {
        releaseDTO = mergedReleaseRefDFS(releaseDTO);
      }

      final version = releaseDTO.version;
      final buildNumber = releaseDTO.buildNumber;
      final status = releaseDTO.status;
      final canIgnoreRelease = releaseDTO.canIgnoreRelease;
      final customData = releaseDTO.customData;
      final publishDateUtc = releaseDTO.publishDateUtc;
      final title = releaseDTO.titleTranslations;
      final description = releaseDTO.descriptionTranslations;
      final releaseNote = releaseDTO.releaseNoteTranslations;
      final releaseDelay = releaseDTO.releaseDelay;
      final reminderPeriod = releaseDTO.reminderPeriod;

      final releaseStores = <Store>[];
      final storesDTO = releaseDTO.stores;
      if (storesDTO == null) {
        releaseStores.addAll(stores);
      } else {
        for (final releaseStoreDTO in storesDTO) {
          final name = releaseStoreDTO.name;
          final url = releaseStoreDTO.url;
          final platforms = releaseStoreDTO.platforms;
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
            customData: releaseStoreDTO.customData ?? globalStore?.customData,
          ));
        }
      }

      releases.add(ReleaseData(
        version: version,
        refVersion: refVersion,
        buildNumber: buildNumber,
        status: status ?? ReleaseStatus.active,
        titleTranslations: title ?? releaseSettings.title,
        descriptionTranslations: description ?? releaseSettings.description,
        releaseNoteTranslations: releaseNote,
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
