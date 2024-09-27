// ignore_for_file: avoid-late-keyword, avoid-non-null-assertion, avoid-unsafe-collection-methods, avoid-similar-names

import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLastUsedSourceName = 'updateChecker_kLastUsedSourceName';
const _kSkippedReleaseVersions = 'updateChecker_kSkippedReleaseVersions';
const _kPostponedReleaseVersions = 'updateChecker_kPostponedReleaseVersions';

class LocalDataService {
  static final _instance = LocalDataService();
  SharedPreferences? _prefs;

  LocalDataService();

  static Future<void> init() async {
    _instance._prefs ??= await SharedPreferences.getInstance();
  }

  static void saveLastSource(String sourceName) {
    _instance._prefs!.setString(_kLastUsedSourceName, sourceName);
  }

  static String? getLastSource() {
    return _instance._prefs!.getString(_kLastUsedSourceName);
  }

  static void addSkippedRelease(String releaseVersion) {
    final skippedReleases = _instance._prefs!.getStringList(_kSkippedReleaseVersions);
    skippedReleases?.add(releaseVersion);
    _instance._prefs!.setStringList(_kSkippedReleaseVersions, skippedReleases ?? []);
  }

  static void addPostponedRelease({required String releaseVersion, required Duration postponeDuration}) {
    final postponedDate = DateTime.now().add(postponeDuration);
    final releaseData = '$releaseVersion/$postponedDate';

    final postponedReleases = _instance._prefs!.getStringList(_kPostponedReleaseVersions);
    postponedReleases?.add(releaseData);
    _instance._prefs!.setStringList(_kPostponedReleaseVersions, postponedReleases ?? []);
  }

  static bool isSkipedRelease(String releaseVersion) {
    final skippedReleases = _instance._prefs!.getStringList(_kSkippedReleaseVersions) ?? [];
    _clearService(releaseVersion);

    return skippedReleases.contains(releaseVersion);
  }

  static bool isPostponedRelease(String releaseVersion) {
    final now = DateTime.now();
    final postponedReleases = _instance._prefs!.getStringList(_kPostponedReleaseVersions) ?? [];
    for (final release in postponedReleases) {
      final postponedData = release.split('/');
      if (postponedData.length == 2) {
        final postponedVersion = postponedData.first;
        final postponedDate = DateTime.tryParse(postponedData[1]);

        if (postponedVersion == releaseVersion && postponedDate != null && now.isBefore(postponedDate)) {
          return true;
        }
      }
    }
    _clearService(releaseVersion);

    return false;
  }

  static Future<void> _clearService(String triggeredVersion) async {
    final skippedReleases = _instance._prefs!.getStringList(_kSkippedReleaseVersions) ?? [];
    if (skippedReleases.length >= 5) {
      try {
        final parsedTriggeredVersion = Version.parse(triggeredVersion);
        skippedReleases.removeWhere((releaseVersion) {
          try {
            return parsedTriggeredVersion > Version.parse(releaseVersion);
          } catch (_) {
            return true;
          }
        });

        await _instance._prefs!.setStringList(_kSkippedReleaseVersions, skippedReleases);
      } catch (_) {}
    }

    final postponedReleases = _instance._prefs!.getStringList(_kPostponedReleaseVersions) ?? [];
    if (postponedReleases.length >= 5) {
      try {
        final now = DateTime.now();
        postponedReleases.removeWhere((releaseData) {
          try {
            final postponedDate = DateTime.parse(releaseData.split('/')[1]);

            return now.isAfter(postponedDate);
          } catch (_) {
            return true;
          }
        });

        await _instance._prefs!.setStringList(_kPostponedReleaseVersions, postponedReleases);
      } catch (_) {}
    }
  }
}
