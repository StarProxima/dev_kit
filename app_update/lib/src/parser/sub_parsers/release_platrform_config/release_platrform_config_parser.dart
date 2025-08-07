// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../base_parsers/update_platform_parser.dart';
import '../../common.dart';
import '../release_source_config/release_source_config_parser.dart';
import 'release_platrform_config.dart';

class ReleasePlatformConfigParser {
  static const _updatePlatformParser = UpdatePlatformParser();
  static const _releaseSourceConfigParser = ReleaseSourceConfigParser();

  const ReleasePlatformConfigParser();

  ReleasePlatformConfig? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    // Short syntax
    if (value is String) {
      final name = _updatePlatformParser.parse(value);

      if (name == null) {
        throw const UpdateConfigException();
      }

      return ReleasePlatformConfig.byRequired(
        platform: name,
        sourceOverride: null,
        customData: null,
      );
    }

    if (value is! Map) {
      throw const UpdateConfigException();
    }

    final map = Map<String, dynamic>.from(value);

    // name
    final nameValue = map.remove('name');
    final name = _updatePlatformParser.parse(nameValue);

    if (name == null) {
      throw const UpdateConfigException();
    }

    // sourceOverride
    final sourceOverrideValue = map.remove('source');
    final sourceOverride = _releaseSourceConfigParser.parse(sourceOverrideValue);

    return ReleasePlatformConfig.byRequired(
      platform: name,
      sourceOverride: sourceOverride,
      customData: map,
    );
  }
}
