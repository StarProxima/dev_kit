import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../default_rules/default_update_config.dart';
import '../models/update_config/update_config.dart';
import '../models/update_search/update_search_config.dart';
import '../resolver/matchers/source_matcher.dart';
import '../searcher/update_search_data_defaulter.dart';
import 'update_config_fetcher.dart';
import 'update_config_source_fetcher.dart';

/// Координатор фетчеров.
class UpdateConfigFetcherCoordinator {
  @protected
  final UpdateSearchDataDefaulter updateSearchDataDefaulter;

  @protected
  final SourceMatcher sourceMatcher;

  const UpdateConfigFetcherCoordinator({
    required this.updateSearchDataDefaulter,
    required this.sourceMatcher,
  });

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

    final searchData = updateSearchDataDefaulter.getSearchDataWithDefaults(
      searchConfig: searchConfig,
      packageInfo: packageInfo,
    );

    final locale = searchData.locale.locale ?? const Locale('en');

    for (final fetcher in fetchers) {
      switch (fetcher) {
        case UpdateConfigSourceFetcher(:final source):
          if (!shouldFetchSourceFetchers) continue;

          final isMatch = sourceMatcher.isMatchBySources(
            ruleSources: [source],
            searchSources: searchData.sources,
            searchPlatform: searchData.platform,
          );

          if (!isMatch) {
            continue;
          }

          try {
            final config = await fetcher.fetchSourceAppUrl(
              locale: locale,
              packageInfo: packageInfo,
            );
            configs.add(config);
            // ignore: avoid_catching_errors
          } on UnimplementedError catch (_) {
          } on Object catch (e, s) {
            // ignore: unawaited_futures
            Future.error(e, s);
          }

          try {
            final config = await fetcher.fetch(
              locale: locale,
              packageInfo: packageInfo,
            );
            configs.add(config);
            // ignore: avoid_catching_errors
          } on UnimplementedError catch (_) {
          } on Object catch (e, s) {
            // ignore: unawaited_futures
            Future.error(e, s);
          }

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
