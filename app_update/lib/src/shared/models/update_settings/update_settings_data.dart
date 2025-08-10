class UpdateSettingsData {
  final Uri updateUrl;
  final bool shouldShow;
  final bool canSkip;
  final bool canPostpone;
  final Duration skipReleaseDelay;
  final Duration skipAllReleasesDelay;
  final Duration postponeReleaseDelay;
  final Duration postponeAllReleasesDelay;
  final Map<String, dynamic>? customData;

  const UpdateSettingsData({
    required this.updateUrl,
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
