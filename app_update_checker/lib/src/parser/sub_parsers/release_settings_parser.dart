// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../update_config_parser.dart';

class ReleaseSettingsParser {
  UpdateStatusWrapperParser get updateStatusWrapperParser => const UpdateStatusWrapperParser();
  DurationParser get _durationParser => const DurationParser();
  TextTranslationsParser get _textParser => const TextTranslationsParser();

  const ReleaseSettingsParser();

  UpdateStatusWrapper<ReleaseSettingsConfig?>? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is! Map<String, dynamic>?) {
      throw const UpdateConfigException();
    }

    if (value == null) return null;

    // title
    final titleValue = value.remove('title');
    final title = _textParser.parseWithStatuses(titleValue, isDebug: isDebug);

    // description
    final descriptionValue = value.remove('description');
    final description = _textParser.parseWithStatuses(descriptionValue, isDebug: isDebug);

    // canSkipRelease
    final canSkipReleaseValue = value.remove('can_skip_release');
    final canSkipRelease = updateStatusWrapperParser.parse(canSkipReleaseValue, (value) {
      if (value is bool?) return value;
      if (isDebug) throw const UpdateConfigException();

      return null;
    });

    // reminderPeriodHours
    final reminderPeriodHours = value.remove('reminder_period_hours');
    final reminderPeriod = _durationParser.parseWithStatuses(hours: reminderPeriodHours, isDebug: isDebug);

    // releaseDelayHours
    final releaseDelayHours = value.remove('release_delay_hours');
    final releaseDelay = _durationParser.parseWithStatuses(hours: releaseDelayHours, isDebug: isDebug);

    // progressiveRolloutHours
    final progressiveRolloutHours = value.remove('progressive_rollout_hours');
    final progressiveRolloutDuration =
        _durationParser.parseWithStatuses(hours: progressiveRolloutHours, isDebug: isDebug);

    final requiredReleaseSettings = ReleaseSettingsConfig(
      titleTranslations: title.required,
      descriptionTranslations: description.required,
      canSkipRelease: canSkipRelease.required,
      reminderPeriod: reminderPeriod.required,
      releaseDelay: releaseDelay.required,
      progressiveRolloutDuration: progressiveRolloutDuration.required,
      customData: value,
    );

    final recommendedReleaseSettings = ReleaseSettingsConfig(
      titleTranslations: title.recommended,
      descriptionTranslations: description.recommended,
      canSkipRelease: canSkipRelease.recommended,
      reminderPeriod: reminderPeriod.recommended,
      releaseDelay: releaseDelay.recommended,
      progressiveRolloutDuration: progressiveRolloutDuration.recommended,
      customData: value,
    );

    final availableReleaseSettings = ReleaseSettingsConfig(
      titleTranslations: title.available,
      descriptionTranslations: description.available,
      canSkipRelease: canSkipRelease.available,
      reminderPeriod: reminderPeriod.available,
      releaseDelay: releaseDelay.available,
      progressiveRolloutDuration: progressiveRolloutDuration.available,
      customData: value,
    );

    return UpdateStatusWrapper(
      required: requiredReleaseSettings,
      recommended: recommendedReleaseSettings,
      available: availableReleaseSettings,
    );
  }
}
