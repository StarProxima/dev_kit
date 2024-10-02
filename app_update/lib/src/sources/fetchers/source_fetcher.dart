import 'dart:async';
import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../localizer/models/release.dart';
import '../source.dart';
import 'app_store_fetcher.dart';
import 'google_play_fetcher.dart';

base class SourceReleaseFetcherCoordinator {
  const SourceReleaseFetcherCoordinator();

  FutureOr<SourceReleaseFetcher> fetcherBySource(Source source) => switch (source.store) {
        Sources.googlePlay => const GooglePlayFetcher(),
        Sources.appStore => const AppStoreFetcher(),
        Sources.custom => throw UnimplementedError(),
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
