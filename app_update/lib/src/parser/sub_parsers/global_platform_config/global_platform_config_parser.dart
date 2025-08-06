// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../base_parsers/update_platform_parser.dart';
import '../../update_config_exception.dart';
import '../global_source_config/global_source_config_parser.dart';
import 'global_platform_config.dart';

class GlobalPlatformConfigParser {
  static const _updatePlatformParser = UpdatePlatformParser();
  static const _globalSourceConfigParser = GlobalSourceConfigParser();

  const GlobalPlatformConfigParser();

  GlobalPlatformConfig? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    // Short syntax
    if (value is String) {
      final name = _updatePlatformParser.parse(value);

      if (name == null) {
        throw const UpdateConfigException();
      }

      return GlobalPlatformConfig.byRequired(
        name: name,
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

    // Разрешаем любые значения name, если строка не пуста
    if (name == null || (name.name.isEmpty)) {
      throw const UpdateConfigException();
    }

    // sourceOverride
    final sourceOverrideValue = map.remove('source');
    final sourceOverride = _globalSourceConfigParser.parse(sourceOverrideValue);

    return GlobalPlatformConfig.byRequired(
      name: name,
      sourceOverride: sourceOverride,
      customData: map,
    );
  }
}
