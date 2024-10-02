import 'package:pub_semver/pub_semver.dart';

import 'update_storage.dart';

class UpdateStorageManager {
  final UpdateStorage _storage;

  const UpdateStorageManager(this._storage);

  bool isSkippedRelease(Version releaseVersion) {
    final skippedReleases = _storage.getSkippedReleases();

    return skippedReleases.contains(releaseVersion);
  }

  bool isPostponedRelease(Version releaseVersion) {
    final postponedReleases = _storage.getPostponedReleases();
    final now = DateTime.now();

    for (final release in postponedReleases) {
      final version = Version.parse(release['version']);
      final date = DateTime.parse(release['date']);
      if (version == releaseVersion && date.isAfter(now)) {
        return true;
      }
    }

    return false;
  }
}
