import 'update_settings_config.dart';

class UpdateSettingsData {
  final bool shouldShow;
  final bool canSkip;
  final bool canPostpone;
  final Duration skipReleaseDelay;
  final Duration skipAllReleasesDelay;
  final Duration postponeReleaseDelay;
  final Duration postponeAllReleasesDelay;
  final Map<String, dynamic>? customParams;

  const UpdateSettingsData({
    required this.shouldShow,
    required this.canSkip,
    required this.canPostpone,
    required this.skipReleaseDelay,
    required this.skipAllReleasesDelay,
    required this.postponeReleaseDelay,
    required this.postponeAllReleasesDelay,
    required this.customParams,
  });

  factory UpdateSettingsData.fromConfig(UpdateSettingsConfig config) {
    return UpdateSettingsData(
      shouldShow:
          config.shouldShow ?? (throw ArgumentError('shouldShow is required')),
      canSkip: config.canSkip ?? (throw ArgumentError('canSkip is required')),
      canPostpone: config.canPostpone ??
          (throw ArgumentError('canPostpone is required')),
      skipReleaseDelay: config.skipReleaseDelay ??
          (throw ArgumentError('skipReleaseDelay is required')),
      skipAllReleasesDelay: config.skipAllReleasesDelay ??
          (throw ArgumentError('skipAllReleasesDelay is required')),
      postponeReleaseDelay: config.postponeReleaseDelay ??
          (throw ArgumentError('postponeReleaseDelay is required')),
      postponeAllReleasesDelay: config.postponeAllReleasesDelay ??
          (throw ArgumentError('postponeAllReleasesDelay is required')),
      customParams: config.customParams,
    );
  }
}
