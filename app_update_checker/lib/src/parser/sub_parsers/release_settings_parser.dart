// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../update_config_parser.dart';

class ReleaseSettingsParser {
  UpdateStatusWrapperParser get updateStatusWrapperParser => const UpdateStatusWrapperParser();
  DurationParser get _durationParser => const DurationParser();
  TextTranslationsParser get _textParser => const TextTranslationsParser();

  BoolParser get _boolParser => const BoolParser();

  const ReleaseSettingsParser();

  UpdateStatusWrapper<ReleaseSettingsConfig?>? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
    // ignore: avoid-long-functions
  }) {
    if (value is! Map<String, dynamic>?) {
      throw const UpdateConfigException();
    }

    if (value == null) return null;

    // title
    final titleValue = value.remove('title');
    final title = _textParser.parseWithStatuses(
      titleValue,
      isDebug: isDebug,
      mode: WrapperMode.all,
    );

    // description
    final descriptionValue = value.remove('description');
    final description = _textParser.parseWithStatuses(
      descriptionValue,
      isDebug: isDebug,
      mode: WrapperMode.all,
    );

    // canSkipRelease
    final canSkipReleaseValue = value.remove('can_skip_release');
    final canSkipRelease = _boolParser.parseWithStatuses(
      canSkipReleaseValue,
      isDebug: isDebug,
      mode: WrapperMode.noRequired,
    );

    // canPostponeRelease
    final canPostponeReleaseValue = value.remove('can_postpone_release');
    final canPostponeRelease = _boolParser.parseWithStatuses(
      canPostponeReleaseValue,
      isDebug: isDebug,
      mode: WrapperMode.noRequired,
    );

    // reminderPeriodHours
    final reminderPeriodHours = value.remove('reminder_period_hours');
    final reminderPeriod = _durationParser.parseWithStatuses(
      hours: reminderPeriodHours,
      isDebug: isDebug,
      mode: WrapperMode.noRequired,
    );

    // releaseDelayHours
    final releaseDelayHours = value.remove('release_delay_hours');
    final releaseDelay = _durationParser.parseWithStatuses(
      hours: releaseDelayHours,
      isDebug: isDebug,
      mode: WrapperMode.noRequired,
    );

    // progressiveRolloutHours
    final progressiveRolloutHours = value.remove('progressive_rollout_hours');
    final progressiveRolloutDuration = _durationParser.parseWithStatuses(
      hours: progressiveRolloutHours,
      isDebug: isDebug,
      mode: WrapperMode.noRequired,
    );

    final requiredReleaseSettings = ReleaseSettingsConfig(
      titleTranslations: title.required,
      descriptionTranslations: description.required,
      canSkipRelease: canSkipRelease.required,
      canPostponeRelease: canPostponeRelease.required,
      reminderPeriod: reminderPeriod.required,
      releaseDelay: releaseDelay.required,
      progressiveRolloutDuration: progressiveRolloutDuration.required,
      customData: value,
    );

    final recommendedReleaseSettings = ReleaseSettingsConfig(
      titleTranslations: title.recommended,
      descriptionTranslations: description.recommended,
      canSkipRelease: canSkipRelease.recommended,
      canPostponeRelease: canPostponeRelease.recommended,
      reminderPeriod: reminderPeriod.recommended,
      releaseDelay: releaseDelay.recommended,
      progressiveRolloutDuration: progressiveRolloutDuration.recommended,
      customData: value,
    );

    final availableReleaseSettings = ReleaseSettingsConfig(
      titleTranslations: title.available,
      descriptionTranslations: description.available,
      canSkipRelease: canSkipRelease.available,
      canPostponeRelease: canPostponeRelease.available,
      reminderPeriod: reminderPeriod.available,
      releaseDelay: releaseDelay.available,
      progressiveRolloutDuration: progressiveRolloutDuration.available,
      customData: value,
    );

    return UpdateStatusWrapper(
      required: requiredReleaseSettings.isEmpty ? null : requiredReleaseSettings,
      recommended: recommendedReleaseSettings.isEmpty ? null : recommendedReleaseSettings,
      available: availableReleaseSettings.isEmpty ? null : availableReleaseSettings,
    );
  }
}
