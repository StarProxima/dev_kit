// ignore_for_file: no-equal-switch-expression-cases

import 'dart:async';

import '../../shared/update_platform.dart';
import '../source.dart';
import '../sources.dart';
import 'app_store_fetcher.dart';
import 'google_play_fetcher.dart';
import 'source_fetcher.dart';

base class SourceReleaseFetcherCoordinator {
  const SourceReleaseFetcherCoordinator();

  FutureOr<SourceReleaseFetcher> fetcherBySourceAndPlatform({Source? source, required UpdatePlatform platform}) =>
      source == null
          ? switch (platform) {
              UpdatePlatform.android => const GooglePlayFetcher(),
              UpdatePlatform.ios => const AppStoreFetcher(),
              _ => throw UnimplementedError(),
            }
          : switch (source.type) {
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
