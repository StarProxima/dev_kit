import 'package:app_update_checker/config/dto/checker_config_dto.dart';
import 'package:app_update_checker/config/entity/stores/store.dart';

import 'checker_config.dart';
import 'release.dart';
import 'stores/stores.dart';

class CheckerConfigParser {
  CheckerConfigParser();

  CheckerConfig parseFromDTO(CheckerConfigDTO checkerConfigDTO) {
    final deprecatedBeforeVersion = checkerConfigDTO.deprecatedBeforeVersion;

    final requiredMinimumVersion = checkerConfigDTO.requiredMinimumVersion;

    final List<Store> stores = [];
    if (checkerConfigDTO.stores != null) {
      for (final storeDTO in checkerConfigDTO.stores!) {
        final name = storeDTO.name;
        final url = storeDTO.url;
        final platforms = storeDTO.platforms;
        if (name != null && url != null && platforms != null) {
          stores.add(CustomStore(
            customName: name,
            url: url,
            platforms: platforms,
          ));
        } else if (name != null && url != null) {
          // TODO take url for default store?
          switch (Stores.fromString(name)) {
            case Stores.googlePlay:
              stores.add(GooglePlay(url: url));
              break;
            case Stores.appStore:
              stores.add(AppStore(url: url));
              break;
            case Stores.customStore:
              throw FormatException('CustomStore must have platforms');
          }
        } else {
          throw FormatException(
            'Can\'t parse store with parameters: $name, $url, $platforms',
          );
        }
      }
    }

    List<Release> releases = [];
    if (checkerConfigDTO.releases != null) {
      for (final releaseDTO in checkerConfigDTO.releases!) {
        final version = releaseDTO.version!; // TODO remove BANG operator
        final isActive = releaseDTO.isActive ?? true;
        final isBroken = releaseDTO.isBroken ?? false;
        final isRequired = releaseDTO.isRequired ?? false;
        final title = releaseDTO.title;
        final description = releaseDTO.description;
        final releaseNote = releaseDTO.releaseNote;
        final releaseDelay = releaseDTO.releaseDelay ?? Duration.zero;
        final reminderPeriod = releaseDTO.reminderPeriod ?? Duration(days: 7);

        final List<Store> releaseStores = [];
        for (final releaseStoreDTO in releaseDTO.stores!) {
          final name = releaseStoreDTO.name;
          final url = releaseStoreDTO.url;
          final platforms = releaseStoreDTO.platforms;
          if (name == null) {
            throw FormatException(
              'Can\'t parse store with parameters: $name, $url, $platforms',
            );
          } else {
            if (url != null && platforms != null) {
              releaseStores.add(CustomStore(
                customName: name,
                url: url,
                platforms: platforms,
              ));
            } else {
              final globalStoreIndex =
                  stores.indexWhere((store) => store.name == name);
              if (globalStoreIndex == -1) {
                throw FormatException(
                  'In release $version used store name, what not contains in global stores',
                );
              } else {
                final globalStore = stores[globalStoreIndex];
                if (url != null) {
                  switch (Stores.fromString(globalStore.name)) {
                    case Stores.googlePlay:
                      releaseStores.add(GooglePlay(url: url));
                      break;
                    case Stores.appStore:
                      releaseStores.add(AppStore(url: url));
                      break;
                    case Stores.customStore:
                      releaseStores.add(CustomStore(
                        customName: globalStore.name,
                        url: url,
                        platforms: platforms ?? globalStore.platforms,
                      ));
                      break;
                  }
                } else {
                  releaseStores.add(CustomStore(
                    customName: globalStore.name,
                    url: url ?? globalStore.url,
                    platforms: platforms ?? globalStore.platforms,
                  ));
                }
              }
            }
          }
        }

        releases.add(Release(
          version: version,
          isActive: isActive,
          isRequired: isRequired,
          isBroken: isBroken,
          title: title ?? {}, // TODO default title?
          description: description ?? {},
          releaseNote: releaseNote ?? {},
          reminderPeriod: reminderPeriod,
          releaseDelay: releaseDelay,
          stores: stores,
        ));
      }
    }

    final customData = checkerConfigDTO.customData ?? <String, dynamic>{};

    return CheckerConfig(
      deprecatedBeforeVersion: deprecatedBeforeVersion,
      requiredMinimumVersion: requiredMinimumVersion,
      stores: stores,
      releases: releases,
      customData: customData,
    );
  }
}
