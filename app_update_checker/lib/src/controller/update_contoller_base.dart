// ignore_for_file: unused_field

import 'dart:async';

import '../builder/models/app_update.dart';
import '../builder/models/exceptions.dart';
import '../linker/models/release_data.dart';

typedef OnUpdateAvailable = FutureOr<void> Function(AppUpdate update);

abstract class UpdateContollerBase {
  Stream<AppUpdate?> get availableUpdateStream;

  /// Check releases from the config and stores.
  Future<void> fetch();

  /// Finds an update
  ///
  /// May throw errors - [UpdateNotFoundException], [UpdateSkippedException], [UpdatePostponedException].
  Future<AppUpdate> findUpdate();

  /// Finds an update
  ///
  /// If update not available return null.
  Future<AppUpdate?> findAvailableUpdate();

  /// Skip a release, a release with this version will no longer be displayed.
  Future<void> skipRelease(ReleaseData release);

  /// Postpone the release, it will display later after a set amount of time.
  Future<void> postponeRelease(ReleaseData release);

  /// Launches a link to the correct store to update the app.
  Future<void> launchReleaseStore(ReleaseData release);
}
