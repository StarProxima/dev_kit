import 'settings_translations.dart';

class ReleaseSettingsConfig {
  final SettingsTranslations? translations;
  final bool? canSkipRelease;
  final bool? canPostponeRelease;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final Duration? progressiveRolloutDuration;
  final Map<String, dynamic>? customData;

  bool get isEmpty =>
      translations == null &&
      canSkipRelease == null &&
      canPostponeRelease == null &&
      reminderPeriod == null &&
      releaseDelay == null &&
      progressiveRolloutDuration == null;

  const ReleaseSettingsConfig({
    required this.translations,
    required this.canSkipRelease,
    required this.canPostponeRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.progressiveRolloutDuration,
    required this.customData,
  });
}
