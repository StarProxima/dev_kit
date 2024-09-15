// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment, dead_code

part of '../update_config_parser.dart';

class ReleaseParser {
  ReleaseSourceParser get _releaseSourceParser => const ReleaseSourceParser();
  ReleaseSettingsParser get _releaseSettingsParser => const ReleaseSettingsParser();
  TextTranslationsParser get _textParser => const TextTranslationsParser();
  VersionParser get _versionParser => const VersionParser();
  DateTimeParser get _dateTimeParser => const DateTimeParser();

  const ReleaseParser();

  ReleaseConfig? parse(
    Map<String, dynamic> map, {
    required bool isDebug,
  }) {
    final isDebugOriginal = isDebug;

    isDebug = true;

    // Если в релизе что-то не спарсилось, то или возращаем ошибку, или null вместо всего релиза,
    // чтобы не возвращать на половину сломанный релиз.
    try {
      // version
      final versionValue = map.remove('version');
      final version = _versionParser.parse(
        versionValue,
        isDebug: isDebug,
      );

      // releaseSettings
      final releaseSettings = _releaseSettingsParser.parse(map, isDebug: isDebug);

      // releaseNote
      final releaseNoteValue = map.remove('release_note');
      final releaseNote = _textParser.parseWithStatuses(
        releaseNoteValue,
        isDebug: isDebug,
        mode: WrapperMode.all,
      );

      // dateUtc
      final dateUtcValue = map.remove('date_utc');
      final dateUtc = _dateTimeParser.parse(dateUtcValue, isDebug: isDebug);

      // sources
      final sourcesValue = map.remove('sources');

      if (sourcesValue is! List<Object>?) throw const UpdateConfigException();

      final sources = sourcesValue
          ?.map(
            (e) => _releaseSourceParser.parse(e, isDebug: isDebug),
          )
          .whereType<ReleaseSourceConfig>()
          .toList();

      return ReleaseConfig(
        version: version,
        dateUtc: dateUtc,
        releaseNoteTranslations: releaseNote,
        releaseSettings: releaseSettings,
        sources: sources,
        customData: map,
      );
    } on UpdateConfigException {
      if (isDebugOriginal) rethrow;

      return null;
    }
  }
}
