// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../checker_config_dto_parser.dart';

class _ReleaseSettingsParser {
  _DurationParser get _durationParser => const _DurationParser();
  _TextParser get _textParser => const _TextParser();
  _VersionParser get _versionParser => const _VersionParser();

  const _ReleaseSettingsParser();

  ReleaseSettingsDTO parse(
    Map<String, dynamic> map, {
    required bool isDebug,
  }) {
    // title
    var title = map.remove('title');

    title = _textParser.parse(title, isDebug: isDebug);
    title as Map<Locale, Object>?;
    title as Map<Locale, String>?;

    // description
    var description = map.remove('description');

    description = _textParser.parse(description, isDebug: isDebug);
    description as Map<Locale, Object>?;
    description as Map<Locale, String>?;

    // canIgnoreRelease
    var canIgnoreRelease = map.remove('can_ignore_release');

    if (canIgnoreRelease is! bool?) {
      if (isDebug) throw const DtoParserException();
      canIgnoreRelease = null;
    }

    // reminderPeriodInHours
    final reminderPeriodInHours = map.remove('reminder_period_hours');
    final reminderPeriod =
        _durationParser.parse(hours: reminderPeriodInHours, isDebug: isDebug);

    // releaseDelayInHours
    final releaseDelayInHours = map.remove('release_delay_hours');
    final releaseDelay =
        _durationParser.parse(hours: releaseDelayInHours, isDebug: isDebug);

    // deprecatedBeforeVersion
    var deprecatedBeforeVersion = map.remove('deprecated_before_version');
    deprecatedBeforeVersion = _versionParser.parse(
      deprecatedBeforeVersion,
      isStrict: false,
      isDebug: isDebug,
    );
    deprecatedBeforeVersion as Version?;

    // requiredMinimumVersion
    var requiredMinimumVersion = map.remove('required_minimum_version');
    requiredMinimumVersion = _versionParser.parse(
      requiredMinimumVersion,
      isStrict: false,
      isDebug: isDebug,
    );
    requiredMinimumVersion as Version?;

    return ReleaseSettingsDTO(
      title: title,
      description: description,
      canIgnoreRelease: canIgnoreRelease,
      reminderPeriod: reminderPeriod,
      releaseDelay: releaseDelay,
      deprecatedBeforeVersion: deprecatedBeforeVersion,
      requiredMinimumVersion: requiredMinimumVersion,
      customData: map,
    );
  }
}
