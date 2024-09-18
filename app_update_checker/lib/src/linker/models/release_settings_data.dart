import '../../parser/models/release_settings_config.dart';
import '../../parser/models/settings_translations.dart';

class ReleaseSettingsData {
  final UpdateTranslations translations;
  final bool canSkipRelease;
  final bool canPostponeRelease;
  final Duration reminderPeriod;
  final Duration releaseDelay;
  final Duration progressiveRolloutDuration;
  final Map<String, dynamic>? customData;

  const ReleaseSettingsData({
    required this.translations,
    required this.canSkipRelease,
    required this.canPostponeRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.progressiveRolloutDuration,
    required this.customData,
  });

  factory ReleaseSettingsData.fromConfig(ReleaseSettingsConfig? config) {
    return ReleaseSettingsData(
      translations: config?.translations ??
          // TODO: Доставить всё из отдельных файлоков сразу в UpdateSettings
          const UpdateTranslations(
            title: {},
            description: {},
            releaseNoteTitle: {},
            skipButtonText: {},
            laterButtonText: {},
            updateButtonText: {},
          ),
      canSkipRelease: config?.canSkipRelease ?? true,
      canPostponeRelease: config?.canPostponeRelease ?? true,
      reminderPeriod: config?.reminderPeriod ?? const Duration(days: 7),
      releaseDelay: config?.releaseDelay ?? Duration.zero,
      progressiveRolloutDuration: config?.progressiveRolloutDuration ?? Duration.zero,
      customData: config?.customData,
    );
  }

  const ReleaseSettingsData.requiredUpdate({
    required this.translations,
    this.canSkipRelease = false,
    this.canPostponeRelease = false,
    this.reminderPeriod = Duration.zero,
    this.releaseDelay = Duration.zero,
    this.progressiveRolloutDuration = Duration.zero,
    this.customData,
  });

  const ReleaseSettingsData.recommendedUpdate({
    required this.translations,
    this.canSkipRelease = false,
    this.canPostponeRelease = true,
    this.reminderPeriod = const Duration(hours: 24),
    this.releaseDelay = Duration.zero,
    this.progressiveRolloutDuration = Duration.zero,
    this.customData,
  });

  const ReleaseSettingsData.availableUpdate({
    required this.translations,
    this.canSkipRelease = true,
    this.canPostponeRelease = true,
    this.reminderPeriod = const Duration(hours: 72),
    this.releaseDelay = Duration.zero,
    this.progressiveRolloutDuration = Duration.zero,
    this.customData,
  });
}
