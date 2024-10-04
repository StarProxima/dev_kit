// ignore_for_file: no-equal-switch-expression-cases

import 'dart:async';
import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../localizer/models/release.dart';
import '../source.dart';
import 'app_store_fetcher.dart';
import 'google_play_fetcher.dart';

base class SourceReleaseFetcherCoordinator {
  const SourceReleaseFetcherCoordinator();

  FutureOr<SourceReleaseFetcher> fetcherBySource(Source source) => switch (source.sourceType) {
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

  Future<Release> fetch({
    required Source source,
    required Locale locale,
    required PackageInfo packageInfo,
  });
}
