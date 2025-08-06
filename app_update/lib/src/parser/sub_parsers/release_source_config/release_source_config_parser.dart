// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../primitive_parsers/string_parser.dart';
import '../../primitive_parsers/uri_parser.dart';
import '../../update_config_exception.dart';

import '../release_config/release_config_parser.dart';
import '../release_platrform_config/release_platrform_config.dart';
import '../release_platrform_config/release_platrform_config_parser.dart';
import 'release_source_config.dart';

class ReleaseSourceConfigParser {
  static const _stringParser = StringParser();
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
      final name = _stringParser.parse(value);
      return ReleaseSourceConfig.byRequired(
        name: name,
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
    final name = _stringParser.parse(nameValue);

    // url
    final urlValue = map.remove('url');
    final url = _uriParser.parse(urlValue);

    // platforms
    final platformsValue = map.remove('platforms');
    if (platformsValue is! List?) throw const UpdateConfigException();

    final platforms = platformsValue
        ?.map(_releasePlatformConfigParser.parse)
        .whereType<ReleasePlatformConfig>()
        .toList();

    // releaseOverride
    final releaseOverrideValue = map.remove('release');
    final releaseOverride = _releaseConfigParser.parse(releaseOverrideValue);

    return ReleaseSourceConfig.byRequired(
      name: name,
      url: url,
      platforms: platforms,
      releaseOverride: releaseOverride,
      customData: map,
    );
  }
}
