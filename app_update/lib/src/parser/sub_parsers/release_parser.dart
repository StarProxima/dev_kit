// ignore_for_file: avoid-collection-mutating-methods

part of '../update_config_parser.dart';

class ReleaseParser {
  ReleaseSourceParser get _releaseSourceParser => const ReleaseSourceParser();
  UpdateSettingsContainerParser get _updateSettingsParser => const UpdateSettingsContainerParser();
  VersionParser get _versionParser => const VersionParser();
  DateTimeParser get _dateTimeParser => const DateTimeParser();

  const ReleaseParser();

  ReleaseConfig? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
    required bool isOverride,
  }) {
    final isDebugOriginal = isDebug;

    if (value is! Map<String, dynamic>?) throw const UpdateConfigException();

    if (value == null) {
      if (isOverride) return null;
      throw const UpdateConfigException();
    }

    final map = value;

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

      if (version == null && !isOverride) throw const UpdateConfigException();

      // date
      final dateValue = map.remove('date');
      final date = _dateTimeParser.parse(dateValue, isDebug: isDebug);

      // settings
      final settingsValue = map.remove('settings');
      final settings = _updateSettingsParser.parse(settingsValue, isDebug: isDebug);

      // sources
      final sourcesValue = map.remove('sources');

      if (sourcesValue is! List<Object>?) throw const UpdateConfigException();

      final sources = sourcesValue
          ?.map(
            (e) => _releaseSourceParser.parse(
              e,
              isDebug: isDebug,
              isOverride: false,
            ),
          )
          .whereType<ReleaseSourceConfig>()
          .toList();

      return ReleaseConfig(
        version: version,
        date: date,
        settings: settings,
        sources: sources,
        customData: map,
      );
    } on UpdateConfigException {
      if (isDebugOriginal) rethrow;

      return null;
    }
  }
}
