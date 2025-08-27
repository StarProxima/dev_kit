// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../models/release/release_config.dart';
import '../base_parsers/update_rules_container_parser.dart';
import '../parse_config_exeption.dart';
import '../primitive_parsers/date_time_parser.dart';
import '../primitive_parsers/list_or_value_parser.dart';
import '../primitive_parsers/version_parser.dart';
import 'release_source_config_parser.dart';

class ReleaseConfigParser {
  static const _versionParser = VersionParser();
  static const _dateTimeParser = DateTimeParser();
  static const _releaseSourceConfigParser = ReleaseSourceConfigParser();
  static const _listOrValueParser = ListOrValueParser();
  static const _updateRulesPartParser = UpdateRulesPartParser();

  const ReleaseConfigParser();

  ReleaseConfig? parse(
    Object? value,
  ) {
    if (value == null) return null;

    if (value is! Map) {
      throw ParseConfigException.wrongType(
        rightType: Map,
        wrongType: value.runtimeType,
        parserType: ReleaseConfigParser,
        configs: [value],
      );
    }

    final map = Map<String, dynamic>.from(value);

    // version
    final versionValue = map.remove('version');
    final version = _versionParser.parse(versionValue);

    if (version == null) {
      throw const ParseConfigException();
    }

    // date
    final dateValue = map.remove('date');
    final date = _dateTimeParser.parse(dateValue);

    if (date == null) {
      throw const ParseConfigException();
    }

    // sources
    final sourcesRawValue = map.remove('sources');
    final sourcesValue = _listOrValueParser.parse(sourcesRawValue);

    final sources =
        sourcesValue?.map(_releaseSourceConfigParser.parse).nonNulls.toList();

    // rules
    final rules = _updateRulesPartParser.parse(map);

    return ReleaseConfig.byRequired(
      version: version,
      date: date,
      sources: sources,
      contentRules: rules?.contentRules,
      settingsRules: rules?.settingsRules,
      appSettingsRules: rules?.appSettingsRules,
      customData: map,
    );
  }
}
