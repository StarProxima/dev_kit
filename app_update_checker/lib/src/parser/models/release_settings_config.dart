import '../../shared/text_translations.dart';

class ReleaseSettingsConfig {
  final TextTranslations? titleTranslations;
  final TextTranslations? descriptionTranslations;
  final bool? canSkipRelease;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final Duration? progressiveRolloutDuration;
  final Map<String, dynamic>? customData;

  const ReleaseSettingsConfig({
    required this.titleTranslations,
    required this.descriptionTranslations,
    required this.canSkipRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.progressiveRolloutDuration,
    required this.customData,
  });
}
