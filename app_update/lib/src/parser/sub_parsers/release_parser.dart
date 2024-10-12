// ignore_for_file: avoid-collection-mutating-methods

part of '../update_config_parser.dart';

class ReleaseParser {
  ReleaseSourceParser get _releaseSourceParser => const ReleaseSourceParser();
  UpdateSettingsParser get _updateSettingsParser => const UpdateSettingsParser();
  VersionParser get _versionParser => const VersionParser();
  DateTimeParser get _dateTimeParser => const DateTimeParser();

  const ReleaseParser();

  ReleaseConfig? parse(
    Map<String, dynamic> map, {
    required bool isDebug,
    required bool isAbleToUseNullVersion,
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

      if (version == null && !isAbleToUseNullVersion) throw const UpdateConfigException();

      // dateUtc
      final dateUtcValue = map.remove('date_utc');
      final dateUtc = _dateTimeParser.parse(dateUtcValue, isDebug: isDebug);

      // releaseSettings
      final updateSettings = _updateSettingsParser.parse(map, isDebug: isDebug);

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
        settings: updateSettings,
        sources: sources,
        customData: map,
      );
    } on UpdateConfigException {
      if (isDebugOriginal) rethrow;

      return null;
    }
  }
}
