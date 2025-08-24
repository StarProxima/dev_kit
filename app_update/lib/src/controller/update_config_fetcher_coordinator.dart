import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../fetcher/update_config_fetcher_base.dart';
import '../shared/models/update/update_config.dart';
import '../shared/models/update_search/update_search_config.dart';
import 'update_searcher.dart';

class UpdateConfigFetcherCoordinator {
  const UpdateConfigFetcherCoordinator({
    required UpdateSearcher updateSearcher,
  }) : _updateSearcher = updateSearcher;

  final UpdateSearcher _updateSearcher;

  Future<List<UpdateConfig>> fetch({
    required List<UpdateConfigFetcherBase> fetchers,
    required UpdateSearchConfig searchConfig,
    required PackageInfo packageInfo,
    bool shouldFetchGlobalSources = true,
    bool shouldFetchConfig = true,
  }) async {
    final configs = <UpdateConfig>[];

    final searchData = _updateSearcher.searchDataFromConfig(
      searchConfig: searchConfig,
      packageInfo: packageInfo,
    );

    for (final fetcher in fetchers) {
      switch (fetcher) {
        case UpdateConfigFetcherGlobal():
          if (!shouldFetchConfig) continue;

        case UpdateConfigFetcherBySource(source: final source):
          if (!shouldFetchGlobalSources) continue;

          if (!searchData.sources.contains(source)) {
            continue;
          }

          if (!(source.platforms?.contains(searchData.platform) ?? false)) {
            continue;
          }
      }

      final locale = searchData.locale.locale ?? const Locale('en');

      final config = await fetcher.fetch(
        locale: locale,
        packageInfo: packageInfo,
      );

      configs.add(config);
    }

    return configs;
  }
}
