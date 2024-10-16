// ignore_for_file: unused_field

import 'dart:async';
import 'dart:ui';

import '../localizer/models/app_update.dart';
import '../localizer/models/release.dart';
import '../localizer/models/update_config.dart';
import 'exceptions.dart';

// TODO (iamgirya): посмотри на спеку и реализацию, тут различия,
// мб надо поменять или спеку, или реализацию
abstract class UpdateControllerBase {
  Stream<AppUpdate?> get availableUpdateStream;

  Stream<UpdateConfig> get updateConfigStream;

  /// Going to network to get the config or using fetchers to get the latest updates from sources.
  ///
  /// [throttleTime] - The time that must have passed since the last fetch to check for updates again.
  // TODO: сделай фетч фетчем - с сохранением инфы с инета
  Future<void> fetch({
    Duration? throttleTime,
  });

  /// Get current update config
  ///
  /// Does not make a new request if the data already exists.
  Future<UpdateConfig?> getAvailableUpdateConfig();

  /// Finds an update
  ///
  /// May throw errors - [UpdateNotFoundException], [UpdateSkippedException], [UpdatePostponedException].
  Future<AppUpdate> findUpdate({
    Locale locale,
  });

  /// Finds an update. Like [findUpdate], but does not throw errors.
  ///
  /// If update not available return null.
  Future<AppUpdate?> findAvailableUpdate({
    Locale locale,
  });

  /// Finds updates from all sources available on the current application platform.
  Future<List<AppUpdate>> findAllAvailableUpdates({
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
