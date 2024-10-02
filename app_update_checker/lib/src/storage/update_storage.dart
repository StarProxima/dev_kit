import 'dart:convert';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLastUsedSourceName = 'updateChecker_kLastUsedSourceName';
const _kSkippedReleaseVersions = 'updateChecker_kSkippedReleaseVersions';
const _kPostponedReleaseVersions = 'updateChecker_kPostponedReleaseVersions';

class UpdateStorage {
  final SharedPreferences _prefs;

  const UpdateStorage(this._prefs);

  Future<void> saveLastSource(String sourceName) async {
    await _prefs.setString(_kLastUsedSourceName, sourceName);
  }

  String? getLastSource() {
    return _prefs.getString(_kLastUsedSourceName);
  }

  Future<void> addSkippedRelease(Version releaseVersion) async {
    final skippedReleases = _prefs.getStringList(_kSkippedReleaseVersions) ?? [];
    skippedReleases.add(releaseVersion.toString());
    await _prefs.setStringList(_kSkippedReleaseVersions, skippedReleases);
  }

  Future<void> addPostponedRelease({
    required Version releaseVersion,
    required Duration postponeDuration,
  }) async {
    final postponedDate = DateTime.now().add(postponeDuration).toIso8601String();
    final releaseData = json.encode({'version': releaseVersion.toString(), 'date': postponedDate});
    final postponedReleases = _prefs.getStringList(_kPostponedReleaseVersions) ?? [];
    postponedReleases.add(releaseData);
    await _prefs.setStringList(_kPostponedReleaseVersions, postponedReleases);
  }

  List<Version> getSkippedReleases() {
    final skippedReleases = _prefs.getStringList(_kSkippedReleaseVersions) ?? [];

    return skippedReleases.map(Version.parse).toList();
  }

  List<Map<String, dynamic>> getPostponedReleases() {
    final postponedReleases = _prefs.getStringList(_kPostponedReleaseVersions) ?? [];

    return postponedReleases.map((e) => json.decode(e) as Map<String, dynamic>).toList();
  }

  Future<void> clearOldReleases() async {
    final now = DateTime.now();
    final postponedReleases = [...?_prefs.getStringList(_kPostponedReleaseVersions)];
    final filteredReleases = postponedReleases.where((release) {
      final data = json.decode(release) as Map<String, dynamic>;
      final postponedDate = DateTime.parse(data['date']);

      return now.isBefore(postponedDate);
    }).toList();

    await _prefs.setStringList(_kPostponedReleaseVersions, filteredReleases);
  }

  Future<void> removeOlderSkippedReleases(
    Version triggeredVersion, {
    int maxStored = 5,
  }) async {
    final skippedReleases = [...?_prefs.getStringList(_kSkippedReleaseVersions)];
    if (skippedReleases.length > maxStored) {
      skippedReleases.removeWhere((releaseVersion) {
        try {
          return Version.parse(releaseVersion) < triggeredVersion;
        } on FormatException catch (_) {
          return true;
        }
      });

      await _prefs.setStringList(_kSkippedReleaseVersions, skippedReleases);
    }
  }
}
