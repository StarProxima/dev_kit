class UpdateSettingsConfig {
  final bool? shouldShow;
  final bool? canSkip;
  final bool? canPostpone;
  final Duration? skipReleaseDelay;
  final Duration? skipAllReleasesDelay;
  final Duration? postponeReleaseDelay;
  final Duration? postponeAllReleasesDelay;
  final Map<String, dynamic>? customData;

  const UpdateSettingsConfig({
    this.shouldShow,
    this.canSkip,
    this.canPostpone,
    this.skipReleaseDelay,
    this.skipAllReleasesDelay,
    this.postponeReleaseDelay,
    this.postponeAllReleasesDelay,
    this.customData,
  });

  const UpdateSettingsConfig.byRequired({
    required this.shouldShow,
    required this.canSkip,
    required this.canPostpone,
    required this.skipReleaseDelay,
    required this.skipAllReleasesDelay,
    required this.postponeReleaseDelay,
    required this.postponeAllReleasesDelay,
    required this.customData,
  });
}
