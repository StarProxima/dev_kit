import '../../linker/models/release_settings_data.dart';
import 'update_texts.dart';

class ReleaseSettings {
  final UpdateTranslations texts;
  final bool canSkipRelease;
  final bool canPostponeRelease;
  final Duration reminderPeriod;
  final Duration releaseDelay;
  final Duration progressiveRolloutDuration;
  final Map<String, dynamic>? customData;

  const ReleaseSettings({
    required this.texts,
    required this.canSkipRelease,
    required this.canPostponeRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.progressiveRolloutDuration,
    required this.customData,
  });

  factory ReleaseSettings.fromData({
    ReleaseSettingsData? data,
    required ReleaseSettings defaultSettings,
  }) =>
      ReleaseSettings(
        texts: UpdateTranslations.fromData(
          rawTranslations: data?.translations,
          defaultTexts: defaultSettings.texts,
        ),
        canSkipRelease: data?.canSkipRelease ?? defaultSettings.canSkipRelease,
        canPostponeRelease: data?.canPostponeRelease ?? defaultSettings.canPostponeRelease,
        reminderPeriod: data?.reminderPeriod ?? defaultSettings.reminderPeriod,
        releaseDelay: data?.releaseDelay ?? defaultSettings.releaseDelay,
        progressiveRolloutDuration: data?.progressiveRolloutDuration ?? defaultSettings.progressiveRolloutDuration,
        customData: data?.customData,
      );

  ReleaseSettings copyWith({
    UpdateTranslations? texts,
    bool? canSkipRelease,
    bool? canPostponeRelease,
    Duration? reminderPeriod,
    Duration? releaseDelay,
    Duration? progressiveRolloutDuration,
    Map<String, dynamic>? customData,
  }) {
    return ReleaseSettings(
      texts: texts ?? this.texts,
      canSkipRelease: canSkipRelease ?? this.canSkipRelease,
      canPostponeRelease: canPostponeRelease ?? this.canPostponeRelease,
      reminderPeriod: reminderPeriod ?? this.reminderPeriod,
      releaseDelay: releaseDelay ?? this.releaseDelay,
      progressiveRolloutDuration: progressiveRolloutDuration ?? this.progressiveRolloutDuration,
      customData: customData ?? this.customData,
    );
  }
}
