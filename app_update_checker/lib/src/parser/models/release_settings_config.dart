import '../../shared/text_translations.dart';

class ReleaseSettingsConfig {
  final TextTranslations? titleTranslations;
  final TextTranslations? descriptionTranslations;
  final bool? canSkipRelease;
  final bool? canPostponeRelease;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final Duration? progressiveRolloutDuration;
  final Map<String, dynamic>? customData;

  bool get isEmpty =>
      titleTranslations == null &&
      descriptionTranslations == null &&
      canSkipRelease == null &&
      canPostponeRelease == null &&
      reminderPeriod == null &&
      releaseDelay == null &&
      progressiveRolloutDuration == null;

  const ReleaseSettingsConfig({
    required this.titleTranslations,
    required this.descriptionTranslations,
    required this.canSkipRelease,
    required this.canPostponeRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.progressiveRolloutDuration,
    required this.customData,
  });
}
