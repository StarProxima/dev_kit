// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../models/release_source/release_source_config.dart';
import '../base_parsers/update_rules_container_parser.dart';
import '../base_parsers/update_source_name_parser.dart';
import '../common.dart';
import 'release_override_config_parser.dart';
import 'release_platrform_config_parser.dart';

class ReleaseSourceConfigParser {
  static const _updateSourceNameParser = UpdateSourceNameParser();
  static const _releasePlatformConfigParser = ReleasePlatformConfigParser();
  static const _releaseOverrideConfigParser = ReleaseOverrideConfigParser();
  static const _updateRulesPartParser = UpdateRulesPartParser();

  const ReleaseSourceConfigParser();

  ReleaseSourceConfig? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    // Short syntax
    if (value is String) {
      final name = _updateSourceNameParser.parse(value);
      if (name == null) throw const UpdateConfigException();

      return ReleaseSourceConfig.byRequired(
        sourceName: name,
        platforms: null,
        releaseOverride: null,
        contentRules: null,
        settingsRules: null,
        appSettingsRules: null,
        customData: null,
      );
    }

    if (value is! Map) {
      throw const UpdateConfigException();
    }

    final map = Map<String, dynamic>.from(value);

    // name
    final nameValue = map.remove('name');
    final name = _updateSourceNameParser.parse(nameValue);
    if (name == null) throw const UpdateConfigException();

    // platforms
    final platformsValue = map.remove('platforms');
    if (platformsValue is! List?) throw const UpdateConfigException();

    final platforms = platformsValue
        ?.map(_releasePlatformConfigParser.parse)
        .nonNulls
        .toList();

    // releaseOverride
    final releaseOverrideValue = map.remove('release_override');
    final releaseOverride =
        _releaseOverrideConfigParser.parse(releaseOverrideValue);

    // rules
    final rules = _updateRulesPartParser.parse(map);

    return ReleaseSourceConfig.byRequired(
      sourceName: name,
      platforms: platforms,
      releaseOverride: releaseOverride,
      contentRules: rules?.contentRules,
      settingsRules: rules?.settingsRules,
      appSettingsRules: rules?.appSettingsRules,
      customData: map,
    );
  }
}
