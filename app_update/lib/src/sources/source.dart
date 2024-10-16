import 'package:flutter/foundation.dart';
import 'package:store_checker/store_checker.dart' as checker;

import '../shared/update_platform.dart';

enum Sources {
  googlePlay,
  appStore,
  googlePlayPackageInstaller,
  amazonAppStore,
  huaweiAppGallery,
  samsungGalaxyStore,
  samsungSmartSwitchMobile,
  xiaomiGetApps,
  oppoAppMarket,
  vivoAppStore,
  ruStore,
  testFlight,
  custom;

  factory Sources.parse(String name) => values.firstWhere(
        (e) => e.name == name,
        orElse: () => custom,
      );

  static Future<Sources?> checkAppSource() async {
    final installationSource = await checker.StoreChecker.getSource;
    final sourceCheckerName = switch (installationSource) {
      checker.Source.IS_INSTALLED_FROM_PLAY_STORE => Sources.googlePlay,
      checker.Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER => Sources.googlePlayPackageInstaller,
      checker.Source.IS_INSTALLED_FROM_AMAZON_APP_STORE => Sources.amazonAppStore,
      checker.Source.IS_INSTALLED_FROM_HUAWEI_APP_GALLERY => Sources.huaweiAppGallery,
      checker.Source.IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE => Sources.samsungGalaxyStore,
      checker.Source.IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE => Sources.samsungSmartSwitchMobile,
      checker.Source.IS_INSTALLED_FROM_XIAOMI_GET_APPS => Sources.xiaomiGetApps,
      checker.Source.IS_INSTALLED_FROM_OPPO_APP_MARKET => Sources.oppoAppMarket,
      checker.Source.IS_INSTALLED_FROM_VIVO_APP_STORE => Sources.vivoAppStore,
      checker.Source.IS_INSTALLED_FROM_TEST_FLIGHT => Sources.testFlight,
      checker.Source.IS_INSTALLED_FROM_RU_STORE => Sources.ruStore,
      checker.Source.IS_INSTALLED_FROM_APP_STORE => Sources.appStore,
      // ignore: avoid-wildcard-cases-with-enums
      _ => null, //  UNKNOWN, IS_INSTALLED_FROM_LOCAL_SOURCE, IS_INSTALLED_FROM_OTHER_SOURCE
    };

    return sourceCheckerName;
  }
}

@immutable
class Source {
  final Sources sourceType;
  final Uri url;
  final List<UpdatePlatform> platforms;
  final Map<String, dynamic>? customData;

  final String? _name;
  String get name => _name ?? sourceType.name;

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

      default:
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
  })  : sourceType = Sources.googlePlay,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Source.appStore({
    required this.url,
    this.customData,
  })  : sourceType = Sources.appStore,
        platforms = const [UpdatePlatform.ios, UpdatePlatform.macos],
        _name = null;

  const Source.googlePlayPackageInstaller({
    required this.url,
    this.customData,
  })  : sourceType = Sources.googlePlayPackageInstaller,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Source.amazonAppStore({
    required this.url,
    this.customData,
  })  : sourceType = Sources.amazonAppStore,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Source.huaweiAppGallery({
    required this.url,
    this.customData,
  })  : sourceType = Sources.huaweiAppGallery,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Source.samsungGalaxyStore({
    required this.url,
    this.customData,
  })  : sourceType = Sources.samsungGalaxyStore,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Source.samsungSmartSwitchMobile({
    required this.url,
    this.customData,
  })  : sourceType = Sources.samsungSmartSwitchMobile,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Source.xiaomiGetApps({
    required this.url,
    this.customData,
  })  : sourceType = Sources.xiaomiGetApps,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Source.oppoAppMarket({
    required this.url,
    this.customData,
  })  : sourceType = Sources.oppoAppMarket,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Source.vivoAppStore({
    required this.url,
    this.customData,
  })  : sourceType = Sources.vivoAppStore,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Source.ruStore({
    required this.url,
    this.customData,
  })  : sourceType = Sources.ruStore,
        platforms = const [UpdatePlatform.android],
        _name = null;

  const Source.testFlight({
    required this.url,
    this.customData,
  })  : sourceType = Sources.testFlight,
        platforms = const [UpdatePlatform.ios, UpdatePlatform.macos],
        _name = null;

  const Source.custom({
    required String name,
    required this.url,
    required this.platforms,
    this.customData,
  })  : sourceType = Sources.custom,
        _name = name;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Source && name == other.name;
}
