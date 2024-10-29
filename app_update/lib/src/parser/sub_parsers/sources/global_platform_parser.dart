// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

part of '../../update_config_parser.dart';

class GlobalPlatformParser {
  GlobalSourceParser get _sourceParser => const GlobalSourceParser();

  const GlobalPlatformParser();

  GlobalPlatformConfig? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is! Map<String, dynamic>) {
      // Short syntax
      if (value is String) {
        return GlobalPlatformConfig(
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
      isOverride: true,
    );

    return GlobalPlatformConfig(
      platform: name,
      source: source,
      customData: map,
    );
  }
}
