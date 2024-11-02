// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment
part of '../../update_config_parser.dart';

class ReleaseSourceParser {
  ReleaseParser get _releaseParser => const ReleaseParser();
  ReleasePlatformParser get _platformParser => const ReleasePlatformParser();

  const ReleaseSourceParser();

  ReleaseSourceConfig? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
    required bool isOverride,
  }) {
    // short string syntax
    if (value is! Map<String, dynamic>) {
      if (value is String) {
        return ReleaseSourceConfig(
          name: value,
          url: null,
          platforms: null,
          release: null,
          customData: null,
        );
      }

      if (isDebug) throw const UpdateConfigException();

      return null;
    }

    // full syntax

    final map = value;

    // name
    final name = map.remove('name');
    if (name is! String?) {
      if (isDebug) throw const UpdateConfigException();

      return null;
    }

    if (!isOverride && name == null) throw const UpdateConfigException();

    // url
    var urlValue = map.remove('url');
    if (urlValue is! String?) {
      if (isDebug) throw const UpdateConfigException();
      urlValue = null;
    }

    Uri? url;

    try {
      url = urlValue == null ? null : Uri.parse(urlValue);
    } catch (e, s) {
      if (isDebug) Error.throwWithStackTrace(const UpdateConfigException(), s);
    }

    // platforms
    final platformsValue = map.remove('platforms');
    if (platformsValue is! List?) throw const UpdateConfigException();

    final platforms = platformsValue
        ?.map((e) => _platformParser.parse(e, isDebug: isDebug))
        .whereType<ReleasePlatformConfig>()
        .toList();

    // release
    final releaseValue = map.remove('release');
    final release = _releaseParser.parse(releaseValue, isDebug: isDebug, isOverride: true);

    return ReleaseSourceConfig(
      name: name,
      url: url,
      platforms: platforms,
      release: release,
      customData: map,
    );
  }
}
