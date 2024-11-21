// ignore_for_file: unused_field

import 'dart:async';
import 'dart:ui';

import '../finalizer/models/app_update.dart';
import '../finalizer/models/release.dart';
import '../finalizer/models/update_config.dart';

abstract class UpdateControllerBase {
  Stream<AppUpdate?> get availableUpdateStream;

  Stream<UpdateConfig> get updateConfigStream;

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
  /// If update founded add data to [availableUpdateStream] and [updateConfigStream]
  ///
  /// May throw errors - [UpdateNotFoundException], [UpdateSkippedException], [UpdatePostponedException].
  /// Does not make a new request if the data already exists.
  Future<AppUpdate> findUpdate({
    Locale locale,
  });

  /// Finds updates from all sources for current platform.
  ///
  /// Does not make a new request if the data already exists.
  Future<List<AppUpdate>> findAllAvailableUpdates({
    Locale locale,
  });

  /// Finds an update. Like [findUpdate], but does not throw errors.
  ///
  /// If update not available return null.
  /// Does not make a new request if the data already exists.
  Future<AppUpdate?> tryFindUpdate({
    Locale locale,
  });

  /// Skip a release, a release with this version will no longer be displayed.
  Future<void> skipRelease(Release release);

  /// Postpone the release, it will display later after a set amount of time.
  Future<void> postponeRelease({
    required Release release,
    required Duration postponeDuration,
  });

  /// Launches a link to the correct store to update the app.
  Future<void> launchReleaseSource(Release release);

  /// Dispose controller.
  Future<void> dispose();
}
