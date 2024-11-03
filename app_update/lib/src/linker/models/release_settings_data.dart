import '../../parser/models/release_settings_config.dart';
import '../../parser/models/settings_translations.dart';

class UpdateSettingsData {
  final UpdateTranslationsData? translations;
  final bool? canSkipRelease;
  final bool? canPostponeRelease;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final Duration? progressiveRolloutDuration;
  final Map<String, dynamic>? customData;

  const UpdateSettingsData({
    required this.translations,
    required this.canSkipRelease,
    required this.canPostponeRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.progressiveRolloutDuration,
    required this.customData,
  });

  factory UpdateSettingsData.fromConfig(UpdateSettingsConfig? config) {
    return UpdateSettingsData(
      translations: config?.translations,
      canSkipRelease: config?.canSkipRelease,
      canPostponeRelease: config?.canPostponeRelease,
      reminderPeriod: config?.reminderPeriod,
      releaseDelay: config?.releaseDelay,
      progressiveRolloutDuration: config?.progressiveRolloutDuration,
      customData: config?.customData,
    );
  }

  const UpdateSettingsData.requiredUpdate({
    required this.translations,
    this.canSkipRelease = false,
    this.canPostponeRelease = false,
    this.reminderPeriod = Duration.zero,
    this.releaseDelay = Duration.zero,
    this.progressiveRolloutDuration = Duration.zero,
    this.customData,
  });

  const UpdateSettingsData.recommendedUpdate({
    required this.translations,
    this.canSkipRelease = false,
    this.canPostponeRelease = true,
    this.reminderPeriod = const Duration(hours: 24),
    this.releaseDelay = Duration.zero,
    this.progressiveRolloutDuration = Duration.zero,
    this.customData,
  });

  const UpdateSettingsData.availableUpdate({
    required this.translations,
    this.canSkipRelease = true,
    this.canPostponeRelease = true,
    this.reminderPeriod = const Duration(hours: 72),
    this.releaseDelay = Duration.zero,
    this.progressiveRolloutDuration = Duration.zero,
    this.customData,
  });

  UpdateSettingsData inherit(UpdateSettingsData child) {
    return UpdateSettingsData(
      translations: child.translations ?? translations,
      canSkipRelease: child.canSkipRelease ?? canSkipRelease,
      canPostponeRelease: child.canPostponeRelease ?? canPostponeRelease,
      reminderPeriod: child.reminderPeriod ?? reminderPeriod,
      releaseDelay: child.releaseDelay ?? releaseDelay,
      progressiveRolloutDuration: child.progressiveRolloutDuration ?? progressiveRolloutDuration,
      customData: child.customData ?? customData,
    );
  }
}
