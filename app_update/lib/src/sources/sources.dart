import 'package:store_checker/store_checker.dart' as checker;

enum Sources {
  googlePlay('Google Play'),
  appStore('AppStore'),
  googlePlayPackageInstaller('Google Play Package Installer'),
  amazonAppStore('Amazon App Store'),
  huaweiAppGallery('App Gallery'),
  samsungGalaxyStore('Galaxy Store'),
  samsungSmartSwitchMobile('Smart Switch Mobile'),
  xiaomiGetApps('GetApps'),
  oppoAppMarket('Oppo AppMarket'),
  vivoAppStore('Vivo AppStore'),
  ruStore('RuStore'),
  testFlight('TestFlight'),
  custom(null),
  ;

  const Sources(this.title);

  final String? title;

  factory Sources.parse(String name) => values.firstWhere(
        (e) =>
            e.name.toLowerCase() == name.toLowerCase() ||
            e.title?.replaceAll(' ', '').toLowerCase() == name.toLowerCase(),
        orElse: () => custom,
      );

  static Future<Sources?> checkAppSource() async {
    final installationSource = await checker.StoreChecker.getSource.onError((_, __) => checker.Source.UNKNOWN);
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
