import '../dto/models/checker_config_dto.dart';
import 'checker_config.dart';
import 'release.dart';
import 'stores/store.dart';

class CheckerConfigParser {
  const CheckerConfigParser();

  // TODO: Зависимость от сторов, сложности при добавлении новых
  // TODO: Avoid long methods. This method contains 107 lines with code.
  // ignore: avoid-long-functions
  CheckerConfig parseFromDTO(CheckerConfigDTO checkerConfigDTO) {
    final deprecatedBeforeVersion = checkerConfigDTO.deprecatedBeforeVersion;

    final requiredMinimumVersion = checkerConfigDTO.requiredMinimumVersion;

    final stores = <Store>[];
    for (final storeDTO in checkerConfigDTO.stores) {
      final name = storeDTO.name;
      final url = storeDTO.url;
      final platforms = storeDTO.platforms;
      if (url != null && platforms != null) {
        stores.add(Store.custom(
          name: name,
          url: url,
          platforms: platforms,
        ));
      } else if (url != null) {
        // TODO take url for default store?
        switch (Stores.parse(name)) {
          case Stores.googlePlay:
            stores.add(Store.googlePlay(url: url));

          case Stores.appStore:
            stores.add(Store.appStore(url: url));

          case Stores.custom:
            throw const FormatException('CustomStore must have platforms');
        }
      } else {
        throw FormatException(
          // ignore: avoid-nullable-interpolation
          "Can't parse store with parameters: $name, $url, $platforms",
        );
      }
    }

    final releases = <Release>[];
    for (final releaseDTO in checkerConfigDTO.releases) {
      final version = releaseDTO.version;
      final isActive = releaseDTO.isActive ?? true;
      final isBroken = releaseDTO.isBroken ?? false;
      final isRequired = releaseDTO.isRequired ?? false;
      final title = releaseDTO.title;
      final description = releaseDTO.description;
      final releaseNote = releaseDTO.releaseNote;
      final releaseDelay = releaseDTO.releaseDelay ?? Duration.zero;
      final reminderPeriod = releaseDTO.reminderPeriod ?? const Duration(days: 7);

      final releaseStores = <Store>[];
      // TODO: Все сторы по умолчанию?
      // ignore: avoid-non-null-assertion
      for (final releaseStoreDTO in releaseDTO.stores!) {
        final name = releaseStoreDTO.name;
        final url = releaseStoreDTO.url;
        final platforms = releaseStoreDTO.platforms;

        // TODO: А если name уже существует в сторах?
        if (url != null && platforms != null) {
          releaseStores.add(Store.custom(
            name: name,
            url: url,
            platforms: platforms,
          ));

          continue;
        }

        final globalStore = List<Store?>.from(stores).firstWhere(
          (store) => store?.name == name,
          orElse: () => null,
        );

        if (globalStore == null) {
          throw FormatException(
            'In release $version used store name, what not contains in global stores',
          );
        }

        if (url == null) {
          releaseStores.add(Store.custom(
            name: globalStore.name,
            url: url ?? globalStore.url,
            platforms: platforms ?? globalStore.platforms,
          ));
          continue;
        }

        switch (Stores.parse(globalStore.name)) {
          case Stores.googlePlay:
            releaseStores.add(Store.googlePlay(url: url));

          case Stores.appStore:
            releaseStores.add(Store.appStore(url: url));

          case Stores.custom:
            releaseStores.add(Store.custom(
              name: globalStore.name,
              url: url,
              platforms: platforms ?? globalStore.platforms,
            ));
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

    final customData = checkerConfigDTO.customData;

    return CheckerConfig(
      deprecatedBeforeVersion: deprecatedBeforeVersion,
      requiredMinimumVersion: requiredMinimumVersion,
      stores: stores,
      releases: releases,
      customData: customData,
    );
  }
}
