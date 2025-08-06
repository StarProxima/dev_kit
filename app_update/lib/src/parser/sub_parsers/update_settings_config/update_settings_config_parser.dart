// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../primitive_parsers/bool_parser.dart';
import '../../primitive_parsers/duration_parser.dart';
import '../../update_config_exception.dart';
import 'update_settings_config.dart';

class UpdateSettingsConfigParser {
  static const _boolParser = BoolParser();
  static const _durationParser = DurationParser();

  const UpdateSettingsConfigParser();

  UpdateSettingsConfig? parse(
    dynamic value,
  ) {
    if (value is! Map<String, dynamic>?) {
      throw const UpdateConfigException();
    }

    if (value == null) return null;

    // shouldShow
    final shouldShowValue = value.remove('should_show');
    final shouldShow = _boolParser.parse(shouldShowValue);

    // canSkip
    final canSkipValue = value.remove('can_skip');
    final canSkip = _boolParser.parse(canSkipValue);

    // canPostpone
    final canPostponeValue = value.remove('can_postpone');
    final canPostpone = _boolParser.parse(canPostponeValue);

    // skipReleaseDelay
    final skipReleaseDelayValue = value.remove('skip_release_delay_hours');
    final skipReleaseDelay = _durationParser.parse(hours: skipReleaseDelayValue);

    // skipAllReleasesDelay
    final skipAllReleasesDelayValue = value.remove('skip_all_releases_delay_hours');
    final skipAllReleasesDelay = _durationParser.parse(hours: skipAllReleasesDelayValue);

    // postponeReleaseDelay
    final postponeReleaseDelayValue = value.remove('postpone_release_delay_hours');
    final postponeReleaseDelay = _durationParser.parse(hours: postponeReleaseDelayValue);

    // postponeAllReleasesDelay
    final postponeAllReleasesDelayValue = value.remove('postpone_all_releases_delay_hours');
    final postponeAllReleasesDelay = _durationParser.parse(hours: postponeAllReleasesDelayValue);

    return UpdateSettingsConfig.byRequired(
      shouldShow: shouldShow,
      canSkip: canSkip,
      canPostpone: canPostpone,
      skipReleaseDelay: skipReleaseDelay,
      skipAllReleasesDelay: skipAllReleasesDelay,
      postponeReleaseDelay: postponeReleaseDelay,
      postponeAllReleasesDelay: postponeAllReleasesDelay,
      customData: value,
    );
  }
}
