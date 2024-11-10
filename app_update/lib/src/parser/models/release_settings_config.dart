class UpdateSettingsConfig {
  final bool? canSkipRelease;
  final bool? canPostponeRelease;
  final Duration? reminderPeriod;
  final Duration? releaseDelay;
  final Duration? progressiveRolloutDuration;
  final Map<String, dynamic>? customData;

  bool get isEmpty =>
      canSkipRelease == null &&
      canPostponeRelease == null &&
      reminderPeriod == null &&
      releaseDelay == null &&
      progressiveRolloutDuration == null;

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
}
