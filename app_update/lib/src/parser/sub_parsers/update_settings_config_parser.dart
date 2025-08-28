// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../models/update_settings/update_settings_config.dart';
import '../base_parsers/custom_params_parser.dart';
import '../parse_config_exeption.dart';
import '../primitive_parsers/bool_parser.dart';
import '../primitive_parsers/duration_parser.dart';

class UpdateSettingsConfigParser {
  static const _boolParser = BoolParser();
  static const _durationParser = DurationParser();
  static const _customParamsParser = CustomParamsParser();

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

    // customParams
    final customParamsValue = map.remove('custom_params');
    final customParams = _customParamsParser.parse(customParamsValue);

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

    // Проверяем, что не осталось неизвестных параметров
    if (map.isNotEmpty) {
      throw ParseConfigException.unexpectedParams(
        params: map,
        parserType: UpdateSettingsConfigParser,
        configs: [value],
      );
    }

    return UpdateSettingsConfig.byRequired(
      shouldShow: shouldShow,
      canSkip: canSkip,
      canPostpone: canPostpone,
      skipReleaseDelay: skipReleaseDelay,
      skipAllReleasesDelay: skipAllReleasesDelay,
      postponeReleaseDelay: postponeReleaseDelay,
      postponeAllReleasesDelay: postponeAllReleasesDelay,
      customParams: customParams,
    );
  }
}
