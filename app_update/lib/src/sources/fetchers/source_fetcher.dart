// ignore_for_file: no-equal-switch-expression-cases

import 'dart:async';
import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../linker/models/release_data.dart';
import '../../parser/models/release_config.dart';
import '../source.dart';
import 'app_store_fetcher.dart';
import 'google_play_fetcher.dart';

base class SourceReleaseFetcherCoordinator {
  const SourceReleaseFetcherCoordinator();

  FutureOr<SourceReleaseFetcher> fetcherBySource(Source source) => switch (source.type) {
        Sources.googlePlay => const GooglePlayFetcher(),
        Sources.appStore => const AppStoreFetcher(),
        Sources.custom => throw UnimplementedError(),
        Sources.googlePlayPackageInstaller => throw UnimplementedError(),
        Sources.amazonAppStore => throw UnimplementedError(),
        Sources.huaweiAppGallery => throw UnimplementedError(),
        Sources.samsungGalaxyStore => throw UnimplementedError(),
        Sources.samsungSmartSwitchMobile => throw UnimplementedError(),
        Sources.xiaomiGetApps => throw UnimplementedError(),
        Sources.oppoAppMarket => throw UnimplementedError(),
        Sources.vivoAppStore => throw UnimplementedError(),
        Sources.ruStore => throw UnimplementedError(),
        Sources.testFlight => throw UnimplementedError(),
      };
}

abstract class SourceReleaseFetcher {
  const SourceReleaseFetcher();

  // Return ReleaseData parsed from source's page.
  // Return null if can't parse. //TODO кидать ошибки или возвращать нулл?
  Future<ReleaseConfig?> fetch({
    required Source source,
    required Locale locale,
    required PackageInfo packageInfo,
  });
}
