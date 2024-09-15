// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment
part of '../update_config_parser.dart';

class ReleaseSourceParser {
  ReleaseParser get _releaseParser => const ReleaseParser();

  const ReleaseSourceParser();

  ReleaseSourceConfig? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
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

    if (name is! String) {
      if (isDebug) throw const UpdateConfigException();

      return null;
    }

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
    var platformsValue = map.remove('platforms');

    if (platformsValue is! List<String>?) {
      if (isDebug) throw const UpdateConfigException();
      platformsValue = null;
    }

    final platforms = platformsValue?.map(UpdatePlatform.new).toList();

    // release
    final release = _releaseParser.parse(map, isDebug: isDebug);

    return ReleaseSourceConfig(
      name: name,
      url: url,
      platforms: platforms,
      release: release,
      customData: map,
    );
  }
}
