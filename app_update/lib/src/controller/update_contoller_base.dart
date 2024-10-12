// ignore_for_file: unused_field

import 'dart:async';
import 'dart:ui';

import '../localizer/models/app_update.dart';
import '../localizer/models/release.dart';
import '../localizer/models/update_config.dart';
import 'exceptions.dart';

abstract class UpdateContollerBase {
  Stream<AppUpdate?> get availableUpdateStream;

  Stream<UpdateConfig> get updateConfigStream;

  /// Fetch update config data from UpdateConfigFetcher.
  Future<void> fetchUpdateConfig();

  /// Fetch releases list data from SourceReleaseFetcherCoordinator and globalSources.
  Future<void> fetchGlobalSourceReleases();

  /// Finds an update from fetched UpdateConfig and global sources releases data
  ///
  /// May throw errors - [UpdateNotFoundException], [UpdateSkippedException], [UpdatePostponedException].
  /// Does not make a new request if the data already exists.
  Future<AppUpdate> findUpdate({
    Locale locale,
  });

  /// Finds an update. Like [findUpdate], but does not throw errors.
  ///
  /// If update not available return null.
  /// Does not make a new request if the data already exists.
  Future<AppUpdate?> tryFindUpdate({
    Locale locale,
  });

  /// Get last founded update config or call [tryFindUpdate].
  Future<UpdateConfig?> getLastUpdateConfig({
    Locale locale,
  });

  /// Get last founded app update or call [tryFindUpdate].
  Future<AppUpdate?> getLastAppUpdate({
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
