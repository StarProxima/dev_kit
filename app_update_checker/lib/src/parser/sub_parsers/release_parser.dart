// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment, dead_code

part of '../update_config_parser.dart';

class ReleaseParser {
  StoreParser get _storeParser => const StoreParser();
  ReleaseSettingsParser get _releaseSettingsParser => const ReleaseSettingsParser();
  TextTranslationsParser get _textParser => const TextTranslationsParser();
  VersionParser get _versionParser => const VersionParser();

  DateTimeParser get _dateTimeParser => const DateTimeParser();

  const ReleaseParser();

  ReleaseConfig? parse(
    Map<String, dynamic> map, {
    required bool isDebug, // ignore: avoid-long-functions
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

      // releaseSettings
      final releaseSettings = _releaseSettingsParser.parse(map, isDebug: isDebug);

      // releaseNote
      final releaseNoteValue = map.remove('release_note');
      final releaseNote = _textParser.parseWithStatuses(releaseNoteValue, isDebug: isDebug);

      // dateUtc
      final dateUtcValue = map.remove('date_utc');
      final dateUtc = _dateTimeParser.parse(dateUtcValue, isDebug: isDebug);

      // stores
      var stores = map.remove('stores');

      if (stores is! List<Object>?) {
        throw const UpdateConfigException();
      } else if (stores != null) {
        stores = stores
            .map((e) => _storeParser.parse(e, isGlobalStore: false, isDebug: isDebug))
            .whereType<SourceConfig>()
            .toList();
      }
      stores as List<SourceConfig>?;

      return ReleaseConfig(
        version: version,
        dateUtc: dateUtc,
        releaseNoteTranslations: releaseNote,
        releaseSettings: releaseSettings,
        sources: stores,
        customData: map,
      );
    } on UpdateConfigException {
      if (isDebugOriginal) rethrow;

      return null;
    }
  }
}
