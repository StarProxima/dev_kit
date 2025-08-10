// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../shared/models/release_source/release_source_config.dart';
import '../base_parsers/update_source_parser.dart';
import '../common.dart';
import '../primitive_parsers/uri_parser.dart';
import 'release_config_parser.dart';
import 'release_platrform_config_parser.dart';

class ReleaseSourceConfigParser {
  static const _updateSourceParser = UpdateSourceParser();
  static const _uriParser = UriParser();
  static const _releasePlatformConfigParser = ReleasePlatformConfigParser();
  static const _releaseConfigParser = ReleaseConfigParser();

  const ReleaseSourceConfigParser();

  ReleaseSourceConfig? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    // Short syntax
    if (value is String) {
      final name = _updateSourceParser.parse(value);
      return ReleaseSourceConfig.byRequired(
        source: name,
        url: null,
        platforms: null,
        releaseOverride: null,
        customData: null,
      );
    }

    if (value is! Map) {
      throw const UpdateConfigException();
    }

    final map = Map<String, dynamic>.from(value);

    // name
    final nameValue = map.remove('name');
    if (nameValue == null) return null;
    final name = _updateSourceParser.parse(nameValue);

    // url
    final urlValue = map.remove('url');
    final url = _uriParser.parse(urlValue);

    // platforms
    final platformsValue = map.remove('platforms');
    if (platformsValue is! List?) throw const UpdateConfigException();

    final platforms = platformsValue?.map(_releasePlatformConfigParser.parse).nonNulls.toList();

    // releaseOverride
    final releaseOverrideValue = map.remove('release');
    final releaseOverride = _releaseConfigParser.parse(releaseOverrideValue);

    return ReleaseSourceConfig.byRequired(
      source: name,
      url: url,
      platforms: platforms,
      releaseOverride: releaseOverride,
      customData: map,
    );
  }
}
