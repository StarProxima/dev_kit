// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../models/update_settings/update_settings_config.dart';
import '../parse_config_exeption.dart';
import '../primitive_parsers/bool_parser.dart';
import '../primitive_parsers/duration_parser.dart';

class UpdateSettingsConfigParser {
  static const _boolParser = BoolParser();
  static const _durationParser = DurationParser();

  const UpdateSettingsConfigParser();

  UpdateSettingsConfig? parse(
    Object? value,
  ) {
    if (value == null) return null;

    if (value is! Map) {
      throw ParseConfigException.wrongType(
        rightType: Map,
        wrongType: value.runtimeType,
        parserType: UpdateSettingsConfigParser,
        configs: [value],
      );
    }

    final map = Map<String, dynamic>.from(value);

    // shouldShow
    final shouldShowValue = map.remove('should_show');
    final shouldShow = _boolParser.parse(shouldShowValue);

    // canSkip
    final canSkipValue = map.remove('can_skip');
    final canSkip = _boolParser.parse(canSkipValue);

    // canPostpone
    final canPostponeValue = map.remove('can_postpone');
    final canPostpone = _boolParser.parse(canPostponeValue);

    // skipReleaseDelay
    final skipReleaseDelayValue = map.remove('skip_release_delay_hours');
    final skipReleaseDelay =
        _durationParser.parse(hours: skipReleaseDelayValue);

    // skipAllReleasesDelay
    final skipAllReleasesDelayValue =
        map.remove('skip_all_releases_delay_hours');
    final skipAllReleasesDelay =
        _durationParser.parse(hours: skipAllReleasesDelayValue);

    // postponeReleaseDelay
    final postponeReleaseDelayValue =
        map.remove('postpone_release_delay_hours');
    final postponeReleaseDelay =
        _durationParser.parse(hours: postponeReleaseDelayValue);

    // postponeAllReleasesDelay
    final postponeAllReleasesDelayValue =
        map.remove('postpone_all_releases_delay_hours');
    final postponeAllReleasesDelay =
        _durationParser.parse(hours: postponeAllReleasesDelayValue);

    return UpdateSettingsConfig.byRequired(
      shouldShow: shouldShow,
      canSkip: canSkip,
      canPostpone: canPostpone,
      skipReleaseDelay: skipReleaseDelay,
      skipAllReleasesDelay: skipAllReleasesDelay,
      postponeReleaseDelay: postponeReleaseDelay,
      postponeAllReleasesDelay: postponeAllReleasesDelay,
      customData: map,
    );
  }
}
