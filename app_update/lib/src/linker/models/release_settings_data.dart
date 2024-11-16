import '../../parser/models/release_settings_config.dart';

class UpdateSettingsData {
  final bool? canSkipRelease;
  final bool? canPostponeRelease;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final Duration? progressiveRolloutDuration;
  final Map<String, dynamic>? customData;

  const UpdateSettingsData({
    this.canSkipRelease,
    this.canPostponeRelease,
    this.reminderPeriod,
    this.releaseDelay,
    this.progressiveRolloutDuration,
    this.customData,
  });

  const UpdateSettingsData.byRequired({
    required this.canSkipRelease,
    required this.canPostponeRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.progressiveRolloutDuration,
    required this.customData,
  });

  factory UpdateSettingsData.fromConfig(UpdateSettingsConfig? config) {
    return UpdateSettingsData.byRequired(
      canSkipRelease: config?.canSkipRelease,
      canPostponeRelease: config?.canPostponeRelease,
      reminderPeriod: config?.reminderPeriod,
      releaseDelay: config?.releaseDelay,
      progressiveRolloutDuration: config?.progressiveRolloutDuration,
      customData: config?.customData,
    );
  }

  UpdateSettingsData inherit(UpdateSettingsData? child) {
    return UpdateSettingsData.byRequired(
      canSkipRelease: child?.canSkipRelease ?? canSkipRelease,
      canPostponeRelease: child?.canPostponeRelease ?? canPostponeRelease,
      reminderPeriod: child?.reminderPeriod ?? reminderPeriod,
      releaseDelay: child?.releaseDelay ?? releaseDelay,
      progressiveRolloutDuration: child?.progressiveRolloutDuration ?? progressiveRolloutDuration,
      customData: child?.customData ?? customData,
    );
  }
}
