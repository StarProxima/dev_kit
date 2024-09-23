import 'dart:async';
import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../parser/models/release_config.dart';
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

  Future<ReleaseConfig> fetch({
    required Source source,
    required Locale locale,
    required PackageInfo packageInfo,
  });
}
