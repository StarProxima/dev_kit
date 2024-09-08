import 'dart:async';
import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../../../config/models/release_dto.dart';
import '../store.dart';
import 'app_store_fetcher.dart';
import 'google_play_fetcher.dart';

base class StoreFetcherCoordinator {
  const StoreFetcherCoordinator();

  FutureOr<StoreFetcher> fetcherByStore(Store store) => switch (store.store) {
        Stores.googlePlay => const GooglePlayFetcher(),
        Stores.appStore => const AppStoreFetcher(),
        Stores.custom => throw UnimplementedError(),
      };
}

abstract class StoreFetcher {
  const StoreFetcher();

  Future<ReleaseDTO> fetch({
    required Store store,
    required Locale locale,
    required PackageInfo packageInfo,
  });
}
