import 'package:yaml/yaml.dart';

import 'checker_config_dto.dart';

class CheckerConfigDTOParser {
  CheckerConfigDTOParser({required this.isDebug});

  final bool isDebug;
  T? _safeParse<T>(T Function() parse) {
    try {
      return parse();
    } catch (e) {
      if (isDebug) rethrow;
      return null;
    }
  }

  CheckerConfigDTO parseFromYaml(String yamlString) {
    final parsedConfig = loadYaml(yamlString);
    return parseFromMap(parsedConfig as Map);
  }

  CheckerConfigDTO parseFromMap(Map configMap) {
    return CheckerConfigDTO(
      deprecatedBeforeVersion: null,
      requiredMinimumVersion: null,
      stores: null,
      releases: null,
      customData: null,
      reminderPeriod: null,
      releaseDelay: null,
    );
    // final deprecatedBeforeVersion =
    //     switch (configMap['deprecatedBeforeVersion']) {
    //   String str => _safeParse(() => Version.parse(str)),
    //   _ => null,
    // };

    // final requiredMinimumVersion =
    //     switch (configMap['requiredMinimumVersion']) {
    //   String str => _safeParse(() => Version.parse(str)),
    //   _ => null,
    // };

    // // TODO свои ошибки
    // List<Store> stores = [];

    // if (configMap['stores'] case List storesList) {
    //   for (final Map storeMap in storesList) {
    //     final String? name = storeMap['name'];
    //     final String? url = storeMap['url'];
    //     final List<String>? platforms = storeMap['platforms'] is List<String>
    //         ? storeMap['platforms']
    //         : null;
    //     if (name != null && url != null && platforms != null) {
    //       stores.add(CustomStore(
    //         customName: name,
    //         url: url,
    //         platforms: platforms,
    //       ));
    //     } else if (name != null && url != null) {
    //       // TODO take url for default store?
    //       switch (Stores.fromString(name)) {
    //         case Stores.googlePlay:
    //           break;
    //         case Stores.appStore:
    //           break;
    //         case Stores.customStore:
    //           break;
    //       }
    //       name;
    //     } else {
    //       if (isDebug) throw FormatException('ti loh');
    //     }
    //   }
    // }

    // List<Release> releases = [];
    // Map customData = {};

    // return CheckerConfig(
    //   deprecatedBeforeVersion: deprecatedBeforeVersion,
    //   requiredMinimumVersion: requiredMinimumVersion,
    //   stores: stores,
    //   releases: releases,
    //   customData: customData,
    // );
  }
}
