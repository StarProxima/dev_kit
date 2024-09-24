import 'package:store_checker/store_checker.dart' as checker;

import '../../localizer/models/release.dart';
import '../source.dart';

class UpdateSourceChecker {
  const UpdateSourceChecker();

// TODO дальше
  // TODO проблема здесь большая в том, что эта штука поможет только для конкретных сторов. В случае с установкой через инет она бесполезна и надо пользоваться только памятью
  /*
  предлагаю так: вначале чекаем память, если нет, чекаем через приоритетный сурс, если нет, то пытаемся определить особый стор, если нет то нулл
  */
  Future<Release?> findAvailableRelease(Map<Source, Release?> availableReleasesBySources) async {
    final sourcesWithReleases = availableReleasesBySources.keys.toList();

    Iterable<Source> source;
    final installationSource = await checker.StoreChecker.getSource;
    switch (installationSource) {
      case checker.Source.IS_INSTALLED_FROM_PLAY_STORE:
        source = sourcesWithReleases.where((source) => source.store == Sources.googlePlay);

      case checker.Source.IS_INSTALLED_FROM_PLAY_PACKAGE_INSTALLER:
        source = sourcesWithReleases.where((source) => source.name == 'googlePackageInstaller');

      case checker.Source.IS_INSTALLED_FROM_LOCAL_SOURCE:
        source = sourcesWithReleases.where((source) => source.name == 'localeSource');

      case checker.Source.IS_INSTALLED_FROM_AMAZON_APP_STORE:
        source = sourcesWithReleases.where((source) => source.name == 'amazonStore');

      case checker.Source.IS_INSTALLED_FROM_HUAWEI_APP_GALLERY:
        source = sourcesWithReleases.where((source) => source.name == 'huaweiAppGalery');

      case checker.Source.IS_INSTALLED_FROM_SAMSUNG_GALAXY_STORE:
        source = sourcesWithReleases.where((source) => source.name == 'samsungGalaxyStore');

      case checker.Source.IS_INSTALLED_FROM_SAMSUNG_SMART_SWITCH_MOBILE:
        source = sourcesWithReleases.where((source) => source.name == 'samsungSmartSwitchMobile');

      case checker.Source.IS_INSTALLED_FROM_XIAOMI_GET_APPS:
        source = sourcesWithReleases.where((source) => source.name == 'xiaomiGetApps');

      case checker.Source.IS_INSTALLED_FROM_OPPO_APP_MARKET:
        source = sourcesWithReleases.where((source) => source.name == 'oppoAppMarket');

      case checker.Source.IS_INSTALLED_FROM_VIVO_APP_STORE:
        source = sourcesWithReleases.where((source) => source.name == 'vivoAppStore');

      case checker.Source.IS_INSTALLED_FROM_RU_STORE:
        source = sourcesWithReleases.where((source) => source.name == 'ruStore');

      case checker.Source.IS_INSTALLED_FROM_OTHER_SOURCE:
        source = sourcesWithReleases.where((source) => source.store == Sources.custom);

      case checker.Source.IS_INSTALLED_FROM_APP_STORE:
        source = sourcesWithReleases.where((source) => source.store == Sources.appStore);

      case checker.Source.IS_INSTALLED_FROM_TEST_FLIGHT:
        source = sourcesWithReleases.where((source) => source.name == 'testFlight');

      case checker.Source.UNKNOWN:
        source = sourcesWithReleases.where((source) => source.store == Sources.custom);
    }

    return availableReleasesBySources[source.firstOrNull];
  }
}
