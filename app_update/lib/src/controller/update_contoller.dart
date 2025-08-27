// ignore_for_file: unused_field

import 'dart:async';

import '../fetcher/update_config_fetcher.dart';
import '../fetcher/update_config_source_fetcher.dart';
import '../models/release/update.dart';
import '../models/update_result/update_result.dart';
import '../models/update_search/update_search_config.dart';
import 'update_controller_impl.dart';

/// Контроллер для поиска обновлений
///
/// You can add custom fetchers
/// ```dart
/// UpdateController(
///   fetchers: [
///     ...UpdateConfigSourceFetcher.defaultFetchers,
///     UpdateConfigFetchercher.byUrl(...),
///   ],
/// )
/// ```
///
abstract interface class UpdateController {
  Stream<void> get onFetch;

  factory UpdateController({
    List<UpdateConfigFetcher> fetchers =
        UpdateConfigSourceFetcher.defaultFetchers,
  }) =>
      UpdateControllerImpl(fetchers: fetchers);

  /// Initialize controller.
  FutureOr<void> init();

  /// Going to network to get the UpdateConfig and Releses from global sources to get the latest updates.
  Future<void> fetch(
    UpdateSearchConfig searchConfig, {
    bool shouldFetchSourceFetchers = true,
    bool shouldFetchFerchers = true,
  });

  /// Finds an update from fetched UpdateConfig and global sources releases data.
  ///
  /// Does not make a new request if the data already exists.
  UpdateResult findUpdate(UpdateSearchConfig searchConfig);

  /// Skip a update, a update with this version will no longer be displayed.
  Future<void> skipUpdate(Update update);

  /// Postpone the update, it will display later after a set amount of time.
  Future<void> postponeUpdate(Update update);

  /// Launches a link to the correct store to update the app.
  Future<void> launchUpdateUrl(Update update);

  /// Dispose controller.
  FutureOr<void> dispose();
}
