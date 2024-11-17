import 'package:flutter/foundation.dart';

import '../shared/update_platform.dart';
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
        return ReleaseSource.googlePlay(url: url, customPlatforms: platforms, customData: customData);

      case Sources.appStore:
        return ReleaseSource.appStore(url: url, customPlatforms: platforms, customData: customData);

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
    List<UpdatePlatform>? customPlatforms,
    this.customData,
  })  : type = Sources.googlePlay,
        platforms = customPlatforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.appStore({
    required this.url,
    List<UpdatePlatform>? customPlatforms,
    this.customData,
  })  : type = Sources.appStore,
        platforms = customPlatforms ?? const [UpdatePlatform.ios, UpdatePlatform.macos],
        _name = null;

  const ReleaseSource.googlePlayPackageInstaller({
    required this.url,
    List<UpdatePlatform>? customPlatforms,
    this.customData,
  })  : type = Sources.googlePlayPackageInstaller,
        platforms = customPlatforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.amazonAppStore({
    required this.url,
    List<UpdatePlatform>? customPlatforms,
    this.customData,
  })  : type = Sources.amazonAppStore,
        platforms = customPlatforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.huaweiAppGallery({
    required this.url,
    List<UpdatePlatform>? customPlatforms,
    this.customData,
  })  : type = Sources.huaweiAppGallery,
        platforms = customPlatforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.samsungGalaxyStore({
    required this.url,
    List<UpdatePlatform>? customPlatforms,
    this.customData,
  })  : type = Sources.samsungGalaxyStore,
        platforms = customPlatforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.samsungSmartSwitchMobile({
    required this.url,
    List<UpdatePlatform>? customPlatforms,
    this.customData,
  })  : type = Sources.samsungSmartSwitchMobile,
        platforms = customPlatforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.xiaomiGetApps({
    required this.url,
    List<UpdatePlatform>? customPlatforms,
    this.customData,
  })  : type = Sources.xiaomiGetApps,
        platforms = customPlatforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.oppoAppMarket({
    required this.url,
    List<UpdatePlatform>? customPlatforms,
    this.customData,
  })  : type = Sources.oppoAppMarket,
        platforms = customPlatforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.vivoAppStore({
    required this.url,
    List<UpdatePlatform>? customPlatforms,
    this.customData,
  })  : type = Sources.vivoAppStore,
        platforms = customPlatforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.ruStore({
    required this.url,
    List<UpdatePlatform>? customPlatforms,
    this.customData,
  })  : type = Sources.ruStore,
        platforms = customPlatforms ?? const [UpdatePlatform.android],
        _name = null;

  const ReleaseSource.testFlight({
    required this.url,
    List<UpdatePlatform>? customPlatforms,
    this.customData,
  })  : type = Sources.testFlight,
        platforms = customPlatforms ?? const [UpdatePlatform.ios, UpdatePlatform.macos],
        _name = null;

  const ReleaseSource.custom({
    required String name,
    required this.url,
    required this.platforms,
    this.customData,
  })  : type = Sources.custom,
        _name = name;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ReleaseSource && name == other.name;
}
