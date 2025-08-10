import '../../parser/sub_parsers/update_settings_config/update_settings_config.dart';

class UpdateSettingsConfig {
  final bool? canSkipRelease;
  final bool? canPostponeRelease;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final Duration? progressiveRolloutDuration;
  final Map<String, dynamic>? customData;

  const UpdateSettingsConfig({
    this.canSkipRelease,
    this.canPostponeRelease,
    this.reminderPeriod,
    this.releaseDelay,
    this.progressiveRolloutDuration,
    this.customData,
  });

  const UpdateSettingsConfig.byRequired({
    required this.canSkipRelease,
    required this.canPostponeRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.progressiveRolloutDuration,
    required this.customData,
  });

  factory UpdateSettingsConfig.fromConfig(UpdateSettingsConfig? config) {
    return UpdateSettingsConfig.byRequired(
      canSkipRelease: config?.canSkipRelease,
      canPostponeRelease: config?.canPostponeRelease,
      reminderPeriod: config?.reminderPeriod,
      releaseDelay: config?.releaseDelay,
      progressiveRolloutDuration: config?.progressiveRolloutDuration,
      customData: config?.customData,
    );
  }

  UpdateSettingsConfig merge(UpdateSettingsConfig? child) {
    final customData = {...?this.customData, ...?child?.customData};

    return UpdateSettingsConfig.byRequired(
      canSkipRelease: child?.canSkipRelease ?? canSkipRelease,
      canPostponeRelease: child?.canPostponeRelease ?? canPostponeRelease,
      reminderPeriod: child?.reminderPeriod ?? reminderPeriod,
      releaseDelay: child?.releaseDelay ?? releaseDelay,
      progressiveRolloutDuration: child?.progressiveRolloutDuration ?? progressiveRolloutDuration,
      customData: customData.isEmpty ? null : customData,
    );
  }
}
