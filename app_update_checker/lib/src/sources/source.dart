import 'package:flutter/foundation.dart';
import 'package:store_checker/store_checker.dart' as checker;

import '../shared/update_platform.dart';

enum Sources {
  googlePlay,
  appStore,
  custom;

  factory Sources.parse(String name) => values.firstWhere(
        (e) => e.name == name,
        orElse: () => custom,
      );

  static Future<String?> checkAppSource() async {
    final installationSource = await checker.StoreChecker.getSource;
    final sourceCheckerName = switch (installationSource) {
      checker.Source.IS_INSTALLED_FROM_PLAY_STORE => Sources.googlePlay.toString(),
      checker.Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER => 'googlePlayPackageInstaller',
      checker.Source.IS_INSTALLED_FROM_AMAZON_APP_STORE => 'amazonAppStore',
      checker.Source.IS_INSTALLED_FROM_HUAWEI_APP_GALLERY => 'huaweiAppGallery',
      checker.Source.IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE => 'samsungGalaxyStore',
      checker.Source.IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE => 'samsungSmartSwitchMobile',
      checker.Source.IS_INSTALLED_FROM_XIAOMI_GET_APPS => 'xiaomiGetApps',
      checker.Source.IS_INSTALLED_FROM_OPPO_APP_MARKET => 'oppoAppMarket',
      checker.Source.IS_INSTALLED_FROM_VIVO_APP_STORE => 'vivoAppStore',
      checker.Source.IS_INSTALLED_FROM_RU_STORE => 'ruStore',
      checker.Source.IS_INSTALLED_FROM_APP_STORE => Sources.appStore.toString(),
      checker.Source.IS_INSTALLED_FROM_TEST_FLIGHT => 'testFlight',
      _ => null //  UNKNOWN, IS_INSTALLED_FROM_LOCAL_SOURCE, IS_INSTALLED_FROM_OTHER_SOURCE
    };
    return sourceCheckerName;
  }
}

@immutable
class Source {
  final Sources store;
  final Uri url;
  final List<UpdatePlatform> platforms;
  final Map<String, dynamic>? customData;

  final String? _name;
  String get name => _name ?? store.name;

  @override
  int get hashCode => name.hashCode;

  factory Source({
    required String name,
    required Uri url,
    required List<UpdatePlatform>? platforms,
    required Map<String, dynamic>? customData,
  }) {
    switch (Sources.parse(name)) {
      case Sources.googlePlay:
        return Source.googlePlay(url: url, customData: customData);

      case Sources.appStore:
        return Source.appStore(url: url, customData: customData);

      case Sources.custom:
        return Source.custom(
          name: name,
          url: url,
          platforms: platforms ?? (throw Exception('Custom source should contains platforms')),
          customData: customData,
        );
    }
  }

  const Source.googlePlay({
    required this.url,
    this.customData,
  })  : store = Sources.googlePlay,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Source.appStore({
    required this.url,
    this.customData,
  })  : store = Sources.appStore,
        platforms = const [UpdatePlatform.ios, UpdatePlatform.macos],
        _name = null;

  const Source.custom({
    required String name,
    required this.url,
    required this.platforms,
    this.customData,
  })  : store = Sources.custom,
        _name = name;

  @override
  bool operator ==(Object other) => other is Source && name == other.name;
}

extension SourceFromStoreChecker on List<Source> {}
