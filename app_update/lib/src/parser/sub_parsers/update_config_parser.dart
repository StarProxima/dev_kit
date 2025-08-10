// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../shared/models/update/update_config.dart';
import '../base_parsers/update_rules_part_parser.dart';
import '../common.dart';
import '../primitive_parsers/list_or_value_parser.dart';
import 'global_source_config_parser.dart';
import 'release_config_parser.dart';

class UpdateConfigParser {
  static const _releaseConfigParser = ReleaseConfigParser();
  static const _globalSourceConfigParser = GlobalSourceConfigParser();
  static const _updateRulesPartParser = UpdateRulesPartParser();
  static const _listOrValueParser = ListOrValueParser();

  const UpdateConfigParser();

  UpdateConfig? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! Map) {
      throw const UpdateConfigException();
    }

    final map = Map<String, dynamic>.from(value);

    // releases
    final releasesRawValue = map.remove('releases');
    final releasesValue = _listOrValueParser.parse(releasesRawValue);

    if (releasesValue == null) throw const UpdateConfigException();

    final releases = releasesValue.map(_releaseConfigParser.parse).nonNulls.toList();

    // sources
    final sourcesRawValue = map.remove('sources');
    final sourcesValue = _listOrValueParser.parse(sourcesRawValue);

    final sources = sourcesValue?.map(_globalSourceConfigParser.parse).nonNulls.toList();

    // rules
    final rules = _updateRulesPartParser.parse(map);

    return UpdateConfig.byRequired(
      releases: releases,
      sources: sources,
      contentRules: rules?.contentRules,
      settingsRules: rules?.settingsRules,
      appStatusRules: rules?.appStatusRules,
      customData: map,
    );
  }
}
