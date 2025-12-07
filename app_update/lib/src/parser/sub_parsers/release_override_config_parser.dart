// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../models/release/release_override_config.dart';
import '../base_parsers/custom_params_parser.dart';
import '../parse_config_exeption.dart';
import '../primitive_parsers/date_time_parser.dart';
import '../primitive_parsers/version_parser.dart';

class ReleaseOverrideConfigParser {
  static const _versionParser = VersionParser();
  static const _dateTimeParser = DateTimeParser();
  static const _customParamsParser = CustomParamsParser();

  const ReleaseOverrideConfigParser();

  ReleaseOverrideConfig? parse(
    Object? value, {
    required bool isDebug,
  }) {
    if (value == null) return null;

    if (value is! Map) {
      throw ParseConfigException.wrongType(
        rightType: Map,
        wrongType: value.runtimeType,
        parserType: ReleaseOverrideConfigParser,
        configs: [value],
      );
    }

    final map = Map<String, dynamic>.from(value);

    // customParams
    final customParamsValue = map.remove('custom_params');
    final customParams = _customParamsParser.parse(customParamsValue);

    // version
    final versionValue = map.remove('version');
    final version = _versionParser.parse(versionValue);

    // date
    final dateValue = map.remove('date');
    final date = _dateTimeParser.parse(dateValue);

    // Проверяем, что не осталось неизвестных параметров
    if (isDebug && map.isNotEmpty) {
      throw ParseConfigException.unexpectedParams(
        params: map,
        parserType: ReleaseOverrideConfigParser,
        configs: [value],
      );
    }

    return ReleaseOverrideConfig.byRequired(
      version: version,
      date: date,
      customParams: customParams,
    );
  }
}
