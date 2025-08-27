import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../default_rules/default_update_config.dart';
import '../models/update_config/update_config.dart';
import '../models/update_search/update_search_config.dart';
import '../searcher/update_search_data_defaulter.dart';
import 'update_config_fetcher.dart';
import 'update_config_source_fetcher.dart';

/// Координатор фетчеров.
class UpdateConfigFetcherCoordinator {
  final UpdateSearchDataDefaulter _updateSearchDataDefaulter;

  const UpdateConfigFetcherCoordinator({
    required UpdateSearchDataDefaulter updateSearchDataDefaulter,
  }) : _updateSearchDataDefaulter = updateSearchDataDefaulter;

  Future<List<UpdateConfig>> fetch({
    required List<UpdateConfigFetcher> fetchers,
    required UpdateSearchConfig searchConfig,
    required PackageInfo packageInfo,
    required bool shouldFetchSourceFetchers,
    required bool shouldFetchFerchers,
  }) async {
    final configs = <UpdateConfig>[
      // Default config from app_update package
      defaultUpdateConfig,
    ];

    final searchData = _updateSearchDataDefaulter.getSearchDataWithDefaults(
      searchConfig: searchConfig,
      packageInfo: packageInfo,
    );

    final locale = searchData.locale.locale ?? const Locale('en');

    for (final fetcher in fetchers) {
      switch (fetcher) {
        case UpdateConfigSourceFetcher(:final source):
          if (!shouldFetchSourceFetchers) continue;

          if (!searchData.sources.contains(source)) {
            continue;
          }

          if (!(source.platforms?.contains(searchData.platform) ?? false)) {
            continue;
          }

          try {
            final config = await fetcher.fetch(
              locale: locale,
              packageInfo: packageInfo,
            );
            configs.add(config);
            // ignore: avoid_catching_errors
          } on UnimplementedError catch (_) {}

        case _:
          if (!shouldFetchFerchers) continue;

          final config = await fetcher.fetch(
            locale: locale,
            packageInfo: packageInfo,
          );
          configs.add(config);
      }
    }

    return configs;
  }
}
