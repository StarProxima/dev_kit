import 'dart:ui';

import '../../parser/models/release_settings_config.dart';
import '../../shared/text_translations.dart';

class ReleaseSettings {
  final TextTranslations titleTranslations;
  final TextTranslations descriptionTranslations;
  final bool canSkipRelease;
  final bool canPostponeRelease;
  final Duration reminderPeriod;
  final Duration releaseDelay;
  final Duration progressiveRolloutDuration;
  final Map<String, dynamic>? customData;

  const ReleaseSettings({
    required this.titleTranslations,
    required this.descriptionTranslations,
    required this.canSkipRelease,
    required this.canPostponeRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.progressiveRolloutDuration,
    required this.customData,
  });

  factory ReleaseSettings.fromConfig(ReleaseSettingsConfig? config) {
    return ReleaseSettings(
      titleTranslations: config?.titleTranslations ?? {const Locale('en'): 'New update'}, // TODO подумать над дефолтным
      descriptionTranslations: config?.descriptionTranslations ?? {const Locale('en'): 'New update'},
      canSkipRelease: config?.canSkipRelease ?? true,
      canPostponeRelease: config?.canPostponeRelease ?? true,
      reminderPeriod: config?.reminderPeriod ?? const Duration(days: 7),
      releaseDelay: config?.releaseDelay ?? Duration.zero,
      progressiveRolloutDuration: config?.progressiveRolloutDuration ?? Duration.zero,
      customData: config?.customData,
    );
  }

  const ReleaseSettings.requiredUpdate({
    required this.titleTranslations,
    required this.descriptionTranslations,
    this.canSkipRelease = false,
    this.canPostponeRelease = false,
    this.reminderPeriod = Duration.zero,
    this.releaseDelay = Duration.zero,
    this.progressiveRolloutDuration = Duration.zero,
    this.customData,
  });

  const ReleaseSettings.recommendedUpdate({
    required this.titleTranslations,
    required this.descriptionTranslations,
    this.canSkipRelease = false,
    this.canPostponeRelease = true,
    this.reminderPeriod = const Duration(hours: 24),
    this.releaseDelay = Duration.zero,
    this.progressiveRolloutDuration = Duration.zero,
    this.customData,
  });

  const ReleaseSettings.availableUpdate({
    required this.titleTranslations,
    required this.descriptionTranslations,
    this.canSkipRelease = true,
    this.canPostponeRelease = true,
    this.reminderPeriod = const Duration(hours: 96),
    this.releaseDelay = Duration.zero,
    this.progressiveRolloutDuration = Duration.zero,
    this.customData,
  });
}
