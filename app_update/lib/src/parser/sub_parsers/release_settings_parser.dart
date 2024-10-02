// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../update_config_parser.dart';

class ReleaseSettingsParser {
  SettingsTranslationsParser get _settingsTranslationsParser => const SettingsTranslationsParser();
  DurationParser get _durationParser => const DurationParser();
  BoolParser get _boolParser => const BoolParser();

  const ReleaseSettingsParser();

  ReleaseSettingsConfig? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is! Map<String, dynamic>?) {
      throw const UpdateConfigException();
    }

    if (value == null) return null;

    // canSkipRelease
    final canSkipReleaseValue = value.remove('can_skip_release');
    final canSkipRelease = _boolParser.parse(
      canSkipReleaseValue,
      isDebug: isDebug,
    );

    // canPostponeRelease
    final canPostponeReleaseValue = value.remove('can_postpone_release');
    final canPostponeRelease = _boolParser.parse(
      canPostponeReleaseValue,
      isDebug: isDebug,
    );

    // reminderPeriodHours
    final reminderPeriodHours = value.remove('reminder_period_hours');
    final reminderPeriod = _durationParser.parse(
      hours: reminderPeriodHours,
      isDebug: isDebug,
    );

    // releaseDelayHours
    final releaseDelayHours = value.remove('release_delay_hours');
    final releaseDelay = _durationParser.parse(
      hours: releaseDelayHours,
      isDebug: isDebug,
    );

    // progressiveRolloutHours
    final progressiveRolloutHours = value.remove('progressive_rollout_hours');
    final progressiveRolloutDuration = _durationParser.parse(
      hours: progressiveRolloutHours,
      isDebug: isDebug,
    );

    // translations
    final translations = _settingsTranslationsParser.parse(
      value,
      isDebug: isDebug,
    );

    return ReleaseSettingsConfig(
      translations: translations,
      canSkipRelease: canSkipRelease,
      canPostponeRelease: canPostponeRelease,
      reminderPeriod: reminderPeriod,
      releaseDelay: releaseDelay,
      progressiveRolloutDuration: progressiveRolloutDuration,
      customData: value,
    );
  }
}
