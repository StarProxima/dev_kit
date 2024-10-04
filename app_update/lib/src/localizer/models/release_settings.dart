import '../../linker/models/release_settings_data.dart';
import 'update_texts.dart';

class ReleaseSettings {
  final UpdateTexts texts;
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
    UpdateTexts? texts,
  }) =>
      ReleaseSettings(
        texts: texts ?? const UpdateTexts(),
        canSkipRelease: data?.canSkipRelease ?? true,
        canPostponeRelease: data?.canPostponeRelease ?? true,
        reminderPeriod: data?.reminderPeriod ?? const Duration(days: 7),
        releaseDelay: data?.releaseDelay ?? Duration.zero,
        progressiveRolloutDuration: data?.progressiveRolloutDuration ?? Duration.zero,
        customData: data?.customData,
      );

  // const ReleaseSettings.requiredUpdate({
  //   required this.texts,
  //   this.canSkipRelease = false,
  //   this.canPostponeRelease = false,
  //   this.reminderPeriod = Duration.zero,
  //   this.releaseDelay = Duration.zero,
  //   this.progressiveRolloutDuration = Duration.zero,
  //   this.customData,
  // });

  // const ReleaseSettings.recommendedUpdate({
  //   required this.texts,
  //   this.canSkipRelease = false,
  //   this.canPostponeRelease = true,
  //   this.reminderPeriod = const Duration(hours: 24),
  //   this.releaseDelay = Duration.zero,
  //   this.progressiveRolloutDuration = Duration.zero,
  //   this.customData,
  // });

  // const ReleaseSettings.availableUpdate({
  //   required this.texts,
  //   this.canSkipRelease = true,
  //   this.canPostponeRelease = true,
  //   this.reminderPeriod = const Duration(hours: 72),
  //   this.releaseDelay = Duration.zero,
  //   this.progressiveRolloutDuration = Duration.zero,
  //   this.customData,
  // });
}
