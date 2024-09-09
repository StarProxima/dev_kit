// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment, dead_code

part of '../update_config_parser.dart';

class ReleaseParser {
  StoreParser get _storeParser => const StoreParser();
  ReleaseSettingsParser get _releaseSettingsParser => const ReleaseSettingsParser();
  TextParser get _textParser => const TextParser();
  VersionParser get _versionParser => const VersionParser();

  const ReleaseParser();

  ReleaseConfig? parse(
    Map<String, dynamic> map, {
    required bool isDebug,
    // ignore: avoid-long-functions
  }) {
    final isDebugOriginal = isDebug;

    isDebug = true;

    // Если в релизе что-то не спарсилось, то или возращаем ошибку, или null вместо всего релиза,
    // чтобы не возвращать на половину сломанный релиз.
    try {
      // version
      var version = map.remove('version');

      version = _versionParser.parse(
        version,
        isDebug: isDebug,
      );

      if (version == null) {
        if (isDebug) throw const UpdateConfigException();

        return null;
      }
      version as Version;

      // refVersion
      var refVersion = map.remove('ref_version');

      refVersion = _versionParser.parse(
        refVersion,
        isDebug: isDebug,
      );
      refVersion as Version?;

      // buildNumber
      var buildNumber = map.remove('build_number');

      if (buildNumber is! int?) {
        if (isDebug) throw const UpdateConfigException();
        buildNumber = null;
      }

      // status
      var status = map.remove('status');
      if (status is! String?) {
        if (isDebug) throw const UpdateConfigException();
        status = null;
      }

      if (status != null) {
        status = ReleaseStatus.parse(status);
        status as ReleaseStatus?;
        if (isDebug && status == null) throw const UpdateConfigException();
      }

      // releaseSettings
      final releaseSettings = _releaseSettingsParser.parse(map, isDebug: isDebug);

      // releaseNote
      var releaseNote = map.remove('release_note');

      releaseNote = _textParser.parse(releaseNote, isDebug: isDebug);
      releaseNote as Map<Locale, Object>?;
      releaseNote as Map<Locale, String>?;

      // publishDateUtc
      var publishDateUtc = map.remove('publish_date_utc');

      if (publishDateUtc is! String?) {
        if (isDebug) throw const UpdateConfigException();
        publishDateUtc = null;
      }

      try {
        publishDateUtc = publishDateUtc == null ? null : DateTime.parse(publishDateUtc);
      } on FormatException catch (e, s) {
        if (isDebug) Error.throwWithStackTrace(const UpdateConfigException(), s);
        publishDateUtc = null;
      }

      publishDateUtc as DateTime?;

      // stores
      var stores = map.remove('stores');

      if (stores is! List<Object>?) {
        throw const UpdateConfigException();
      } else if (stores != null) {
        stores = stores
            .map((e) => _storeParser.parse(e, isGlobalStore: false, isDebug: isDebug))
            .whereType<StoreConfig>()
            .toList();
      }
      stores as List<StoreConfig>?;

      return ReleaseConfig(
        version: version,
        refVersion: refVersion,
        buildNumber: buildNumber,
        status: status,
        titleTranslations: releaseSettings.titleTranslations,
        descriptionTranslations: releaseSettings.descriptionTranslations,
        releaseNoteTranslations: releaseNote,
        publishDateUtc: publishDateUtc,
        canIgnoreRelease: releaseSettings.canIgnoreRelease,
        reminderPeriod: releaseSettings.reminderPeriod,
        releaseDelay: releaseSettings.releaseDelay,
        stores: stores,
        customData: map,
      );
    } on UpdateConfigException {
      if (isDebugOriginal) rethrow;

      return null;
    }
  }
}
