import 'package:flutter/foundation.dart';

import '../shared/update_entities/update_platform.dart';
import 'sources.dart';

@immutable
class ReleaseSource {
  final Sources type;
  final Uri url;
  final List<UpdatePlatform> platforms;
  final Map<String, dynamic>? customData;

  final String? _name;
  String get name => _name ?? type.name;

  String get title => type.title ?? name;

  @override
  int get hashCode => name.hashCode;

  factory ReleaseSource({
    required String name,
    required Uri url,
    required List<UpdatePlatform>? platforms,
    required Map<String, dynamic>? customData,
  }) {
    switch (Sources.parse(name)) {
      case Sources.googlePlay:
        return ReleaseSource.googlePlay(url: url, platforms: platforms, customData: customData);

      case Sources.appStore:
        return ReleaseSource.appStore(url: url, platforms: platforms, customData: customData);

      case Sources.googlePlayPackageInstaller:
        return ReleaseSource.googlePlayPackageInstaller(
            url: url, platforms: platforms, customData: customData);

      case Sources.amazonAppStore:
        return ReleaseSource.amazonAppStore(url: url, platforms: platforms, customData: customData);

      case Sources.huaweiAppGallery:
        return ReleaseSource.huaweiAppGallery(
            url: url, platforms: platforms, customData: customData);

      case Sources.samsungGalaxyStore:
        return ReleaseSource.samsungGalaxyStore(
            url: url, platforms: platforms, customData: customData);

      case Sources.samsungSmartSwitchMobile:
        return ReleaseSource.samsungSmartSwitchMobile(
            url: url, platforms: platforms, customData: customData);

      case Sources.xiaomiGetApps:
        return ReleaseSource.xiaomiGetApps(url: url, platforms: platforms, customData: customData);

      case Sources.oppoAppMarket:
        return ReleaseSource.oppoAppMarket(url: url, platforms: platforms, customData: customData);

      case Sources.vivoAppStore:
        return ReleaseSource.vivoAppStore(url: url, platforms: platforms, customData: customData);

      case Sources.ruStore:
        return ReleaseSource.ruStore(url: url, platforms: platforms, customData: customData);

      case Sources.testFlight:
        return ReleaseSource.testFlight(url: url, platforms: platforms, customData: customData);

      default:
        return ReleaseSource.custom(
          name: name,
          url: url,
          platforms: platforms ?? (throw Exception('Custom source should contains platforms')),
          customData: customData,
        );
    }
  }

  const ReleaseSource.googlePlay({
    required this.url,
    List<UpdatePlatform>? platforms,
    this.customData,
  })  : type = Sources.googlePlay,
        platforms = platforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.appStore({
    required this.url,
    List<UpdatePlatform>? platforms,
    this.customData,
  })  : type = Sources.appStore,
        platforms = platforms ?? const [UpdatePlatform.ios, UpdatePlatform.macos],
        _name = null;

  const ReleaseSource.googlePlayPackageInstaller({
    required this.url,
    List<UpdatePlatform>? platforms,
    this.customData,
  })  : type = Sources.googlePlayPackageInstaller,
        platforms = platforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.amazonAppStore({
    required this.url,
    List<UpdatePlatform>? platforms,
    this.customData,
  })  : type = Sources.amazonAppStore,
        platforms = platforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.huaweiAppGallery({
    required this.url,
    List<UpdatePlatform>? platforms,
    this.customData,
  })  : type = Sources.huaweiAppGallery,
        platforms = platforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.samsungGalaxyStore({
    required this.url,
    List<UpdatePlatform>? platforms,
    this.customData,
  })  : type = Sources.samsungGalaxyStore,
        platforms = platforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.samsungSmartSwitchMobile({
    required this.url,
    List<UpdatePlatform>? platforms,
    this.customData,
  })  : type = Sources.samsungSmartSwitchMobile,
        platforms = platforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.xiaomiGetApps({
    required this.url,
    List<UpdatePlatform>? platforms,
    this.customData,
  })  : type = Sources.xiaomiGetApps,
        platforms = platforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.oppoAppMarket({
    required this.url,
    List<UpdatePlatform>? platforms,
    this.customData,
  })  : type = Sources.oppoAppMarket,
        platforms = platforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.vivoAppStore({
    required this.url,
    List<UpdatePlatform>? platforms,
    this.customData,
  })  : type = Sources.vivoAppStore,
        platforms = platforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.ruStore({
    required this.url,
    List<UpdatePlatform>? platforms,
    this.customData,
  })  : type = Sources.ruStore,
        platforms = platforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.testFlight({
    required this.url,
    List<UpdatePlatform>? platforms,
    this.customData,
  })  : type = Sources.testFlight,
        platforms = platforms ?? const [UpdatePlatform.ios, UpdatePlatform.macos],
        _name = null;

  const ReleaseSource.custom({
    required String name,
    required this.url,
    required this.platforms,
    this.customData,
  })  : type = Sources.custom,
        _name = name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ReleaseSource && name == other.name;
}
