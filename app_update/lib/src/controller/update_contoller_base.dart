// ignore_for_file: unused_field

import 'dart:async';
import 'dart:ui';

import '../shared/models/release/update.dart';
import '../shared/models/update_result/update_result.dart';
import '../shared/models/update_search/update_search_config.dart';

abstract class UpdateControllerBase {
  /// Going to network to get the UpdateConfig and Releses from global sources to get the latest updates.
  Future<void> fetch({
    Locale locale,
    bool shouldFetchGlobalSources = true,
    bool shouldFetchConfig = true,
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
  Future<void> dispose();
}
