import '../../parser/sub_parsers/update_settings_config/update_settings_config.dart';
import 'mergeable.dart';

class UpdateSettingsData extends UpdateSettingsConfig with Mergeable {
  UpdateSettingsData({
    required super.shouldShow,
    required super.canSkip,
    required super.canPostpone,
    required super.skipReleaseDelay,
    required super.skipAllReleasesDelay,
    required super.postponeReleaseDelay,
    required super.postponeAllReleasesDelay,
    required super.customData,
  });

  @override
  UpdateSettingsData merge(covariant UpdateSettingsData other) => UpdateSettingsData(
        shouldShow: other.shouldShow ?? shouldShow,
        canSkip: other.canSkip ?? canSkip,
        canPostpone: other.canPostpone ?? canPostpone,
        skipReleaseDelay: other.skipReleaseDelay ?? skipReleaseDelay,
        skipAllReleasesDelay: other.skipAllReleasesDelay ?? skipAllReleasesDelay,
        postponeReleaseDelay: other.postponeReleaseDelay ?? postponeReleaseDelay,
        postponeAllReleasesDelay: other.postponeAllReleasesDelay ?? postponeAllReleasesDelay,
        customData: mergeCustomData(customData, other.customData),
      );
}
