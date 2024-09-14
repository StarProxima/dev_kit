// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../update_config_parser.dart';

class ReleaseSettingsParser {
  DurationParser get _durationParser => const DurationParser();
  TextParser get _textParser => const TextParser();
  VersionParser get _versionParser => const VersionParser();

  const ReleaseSettingsParser();

  ReleaseSettingsConfig parse(
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
      if (isDebug) throw const UpdateConfigException();
      canIgnoreRelease = null;
    }

    // reminderPeriodInHours
    final reminderPeriodInHours = map.remove('reminder_period_hours');
    final reminderPeriod = _durationParser.parse(hours: reminderPeriodInHours, isDebug: isDebug);

    // releaseDelayInHours
    final releaseDelayInHours = map.remove('release_delay_hours');
    final releaseDelay = _durationParser.parse(hours: releaseDelayInHours, isDebug: isDebug);

    // deprecatedBeforeVersion
    var deprecatedBeforeVersion = map.remove('deprecated_before_version');
    deprecatedBeforeVersion = _versionParser.parse(
      deprecatedBeforeVersion,
      isDebug: isDebug,
    );
    deprecatedBeforeVersion as Version?;

    // requiredMinimumVersion
    var requiredMinimumVersion = map.remove('required_minimum_version');
    requiredMinimumVersion = _versionParser.parse(
      requiredMinimumVersion,
      isDebug: isDebug,
    );
    requiredMinimumVersion as Version?;

    return ReleaseSettingsConfig(
      titleTranslations: title,
      descriptionTranslations: description,
      canSkipRelease: canIgnoreRelease,
      reminderPeriod: reminderPeriod,
      releaseDelay: releaseDelay,
      deprecatedBeforeVersion: deprecatedBeforeVersion,
      requiredMinimumVersion: requiredMinimumVersion,
      customData: map,
    );
  }
}
