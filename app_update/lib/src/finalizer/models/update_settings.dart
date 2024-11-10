import '../../linker/models/release_settings_data.dart';

class UpdateSettings {
  final bool canSkipRelease;
  final bool canPostponeRelease;
  final Duration reminderPeriod;
  final Duration releaseDelay;
  final Duration progressiveRolloutDuration;
  final Map<String, dynamic>? customData;

  const UpdateSettings({
    required this.canSkipRelease,
    required this.canPostponeRelease,
    required this.reminderPeriod,
    required this.releaseDelay,
    required this.progressiveRolloutDuration,
    required this.customData,
  });

  const UpdateSettings.base({
    this.canSkipRelease = true,
    this.canPostponeRelease = true,
    this.reminderPeriod = const Duration(hours: 36),
    this.releaseDelay = Duration.zero,
    this.progressiveRolloutDuration = Duration.zero,
    this.customData,
  });

  UpdateSettings merge(
    UpdateSettingsData? data,
  ) {
    final customData = {...?this.customData, ...?data?.customData};

    return UpdateSettings(
      canSkipRelease: data?.canSkipRelease ?? canSkipRelease,
      canPostponeRelease: data?.canPostponeRelease ?? canPostponeRelease,
      reminderPeriod: data?.reminderPeriod ?? reminderPeriod,
      releaseDelay: data?.releaseDelay ?? releaseDelay,
      progressiveRolloutDuration: data?.progressiveRolloutDuration ?? progressiveRolloutDuration,
      customData: customData.isEmpty ? null : customData,
    );
  }

  UpdateSettings copyWith({
    bool? canSkipRelease,
    bool? canPostponeRelease,
    Duration? reminderPeriod,
    Duration? releaseDelay,
    Duration? progressiveRolloutDuration,
    Map<String, dynamic>? customData,
  }) {
    return UpdateSettings(
      canSkipRelease: canSkipRelease ?? this.canSkipRelease,
      canPostponeRelease: canPostponeRelease ?? this.canPostponeRelease,
      reminderPeriod: reminderPeriod ?? this.reminderPeriod,
      releaseDelay: releaseDelay ?? this.releaseDelay,
      progressiveRolloutDuration: progressiveRolloutDuration ?? this.progressiveRolloutDuration,
      customData: customData ?? this.customData,
    );
  }
}
