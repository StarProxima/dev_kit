import 'package:app_update_checker/config/checker_config.dart';
import 'package:yaml/yaml.dart';

import 'release.dart';
import 'stores/store.dart';
import 'version.dart';

class ConfigParser {
  ConfigParser({required this.isDebug});

  final bool isDebug;
  T? _safeParse<T>(T Function() parse) {
    try {
      return parse();
    } catch (e) {
      if (isDebug) rethrow;
      return null;
    }
  }

  CheckerConfig parseFromYaml(String yamlString) {
    final parsedConfig = loadYaml(yamlString);
    return parseFromMap(parsedConfig as Map);
  }

  CheckerConfig parseFromMap(Map configMap) {
    final deprecatedBeforeVersion =
        switch (configMap['deprecatedBeforeVersion']) {
      String str => _safeParse(() => Version.parse(str)),
      _ => null,
    };

    final requiredMinimumVersion =
        switch (configMap['requiredMinimumVersion']) {
      String str => _safeParse(() => Version.parse(str)),
      _ => null,
    };

    // TODO свои ошибки
    List<Store> stores = [];

    if (configMap['stores'] case List storesList) {
      for (final Map storeMap in storesList) {
        final String? name = storeMap['name'];
        final String? url = storeMap['url'];
        final List<String>? platforms = storeMap['platforms'] is List<String>
            ? storeMap['platforms']
            : null;
        if (name != null && url != null && platforms != null) {
          stores.add(
              CustomStore(customName: name, url: url, platforms: platforms));
          // TODO take url for default store
        } else if (name != null && url != null) {
          name; // TODO work in progress
        } else {
          if (isDebug) throw FormatException('ti loh');
        }
      }
    }

    List<Release> releases = [];
    Map customData = {};

    return CheckerConfig(
      deprecatedBeforeVersion: deprecatedBeforeVersion,
      requiredMinimumVersion: requiredMinimumVersion,
      stores: stores,
      releases: releases,
      customData: customData,
    );
  }
}
