// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../../update_config_parser.dart';

class ReleasePlatformParser {
  ReleaseSourceParser get _sourceParser => const ReleaseSourceParser();

  const ReleasePlatformParser();

  ReleasePlatformConfig? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is! Map<String, dynamic>) {
      // Short syntax
      if (value is String) {
        return ReleasePlatformConfig(
          platform: UpdatePlatform(value),
          source: null,
          customData: null,
        );
      }

      if (isDebug) throw const UpdateConfigException();

      return null;
    }

    final map = value;

    // name
    final nameValue = map.remove('name');
    if (nameValue is! String) throw const UpdateConfigException();
    final name = UpdatePlatform(nameValue);

    // source
    final sourceValue = map.remove('source');
    final source = _sourceParser.parse(
      sourceValue,
      isDebug: isDebug,
    );

    return ReleasePlatformConfig(
      platform: name,
      source: source,
      customData: map,
    );
  }
}
