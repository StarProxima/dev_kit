// ignore_for_file: unused_field

import 'dart:async';

import '../localizer/models/app_update.dart';
import '../localizer/models/release.dart';
import '../localizer/models/update_config.dart';
import 'exceptions.dart';

abstract class UpdateContollerBase {
  Stream<AppUpdate?> get availableUpdateStream;

  Stream<UpdateConfig> get updateConfigStream;

  /// Check new releases from the update config and stores.
  Future<void> fetch();

  /// Get current update config
  ///
  /// Does not make a new request if the data already exists.
  Future<UpdateConfig?> getAvailableUpdateConfig();

  /// Finds an update
  ///
  /// May throw errors - [UpdateNotFoundException], [UpdateSkippedException], [UpdatePostponedException].
  Future<AppUpdate> findUpdate();

  /// Finds an update
  ///
  /// If update not available return null.
  Future<AppUpdate?> getAvailableAppUpdate();

  /// Skip a release, a release with this version will no longer be displayed.
  Future<void> skipRelease(Release release);

  /// Postpone the release, it will display later after a set amount of time.
  Future<void> postponeRelease({required Release release, required Duration postponeDuration});

  /// Launches a link to the correct store to update the app.
  Future<void> launchReleaseSource(Release release);

  /// Dispose controller.
  Future<void> dispose();
}
