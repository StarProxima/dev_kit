import '../../linker/models/release_settings_data.dart';
import 'update_texts.dart';

class UpdateSettings {
  final UpdateTranslations translations;
  final bool canSkipRelease;
  final bool canPostponeRelease;
  final Duration reminderPeriod;
  final Duration releaseDelay;
  final Duration progressiveRolloutDuration;
  final Map<String, dynamic>? customData;

  const UpdateSettings({
    required this.translations,
    required this.canSkipRelease,
    required this.canPostponeRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.progressiveRolloutDuration,
    required this.customData,
  });

  const UpdateSettings.base({
    required this.translations,
    this.canSkipRelease = true,
    this.canPostponeRelease = true,
    this.reminderPeriod = const Duration(hours: 36),
    this.releaseDelay = Duration.zero,
    this.progressiveRolloutDuration = Duration.zero,
    this.customData,
  });

  factory UpdateSettings.fromData({
    UpdateSettingsData? data,
  }) {
    // TODO: Доставать всё из DefaultUpdateSettingsContainer
    final defaultSettings = UpdateSettings.base(
      translations: UpdateTranslations.base(),
    );

    return UpdateSettings(
      translations: UpdateTranslations.fromData(
        rawTranslations: data?.translations,
        defaultTexts: defaultSettings.translations,
      ),
      canSkipRelease: data?.canSkipRelease ?? defaultSettings.canSkipRelease,
      canPostponeRelease: data?.canPostponeRelease ?? defaultSettings.canPostponeRelease,
      reminderPeriod: data?.reminderPeriod ?? defaultSettings.reminderPeriod,
      releaseDelay: data?.releaseDelay ?? defaultSettings.releaseDelay,
      progressiveRolloutDuration: data?.progressiveRolloutDuration ?? defaultSettings.progressiveRolloutDuration,
      customData: data?.customData,
    );
  }

  UpdateSettings copyWith({
    UpdateTranslations? translations,
    bool? canSkipRelease,
    bool? canPostponeRelease,
    Duration? reminderPeriod,
    Duration? releaseDelay,
    Duration? progressiveRolloutDuration,
    Map<String, dynamic>? customData,
  }) {
    return UpdateSettings(
      translations: translations ?? this.translations,
      canSkipRelease: canSkipRelease ?? this.canSkipRelease,
      canPostponeRelease: canPostponeRelease ?? this.canPostponeRelease,
      reminderPeriod: reminderPeriod ?? this.reminderPeriod,
      releaseDelay: releaseDelay ?? this.releaseDelay,
      progressiveRolloutDuration: progressiveRolloutDuration ?? this.progressiveRolloutDuration,
      customData: customData ?? this.customData,
    );
  }
}
