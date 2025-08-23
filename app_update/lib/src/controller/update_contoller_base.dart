// ignore_for_file: unused_field

import 'dart:async';
import 'dart:ui';

import '../shared/models/release/update.dart';
import '../shared/models/update/update_config.dart';
import '../shared/models/update_result/update_result.dart';
import '../shared/models/update_search/update_search_config.dart';

abstract class UpdateControllerBase {
  Stream<UpdateResult> get updateResultStream;
  Stream<UpdateConfig> get updateConfigStream;

  UpdateResult? get updateResult;
  UpdateConfig? get updateConfig;

  /// Going to network to get the UpdateConfig and Releses from global sources to get the latest updates.
  Future<void> fetch({
    Locale locale,
  });

  /// Going to network to get the UpdateConfig to get the latest updates from sources.
  Future<void> fetchUpdateConfig();

  /// Fetch releases list data from SourceReleaseFetcherCoordinator and globalSources.
  Future<void> fetchGlobalSourceReleases({
    Locale locale,
  });

  /// Finds an update from fetched UpdateConfig and global sources releases data.
  /// If update founded add data to [updateResultStream] and [updateConfigStream]
  ///
  /// Does not make a new request if the data already exists.
  Future<UpdateResult> findUpdate(UpdateSearchConfig searchConfig);

  /// Skip a update, a update with this version will no longer be displayed.
  Future<void> skipUpdate(Update update);

  /// Postpone the update, it will display later after a set amount of time.
  Future<void> postponeUpdate({
    required Update update,
    required Duration postponeDuration,
  });

  /// Launches a link to the correct store to update the app.
  Future<void> launchUpdateUrl(Update update);

  /// Dispose controller.
  Future<void> dispose();
}
