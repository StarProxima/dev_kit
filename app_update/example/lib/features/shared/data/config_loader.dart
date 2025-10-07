import 'package:app_update/app_update.dart';
import 'package:flutter/services.dart';
import 'package:yaml/yaml.dart';

import '../domain/update_config_type.dart';

/// Загружает конфигурации из assets
class ConfigLoader {
  const ConfigLoader();

  /// Создает UpdateConfigFetcher для указанного типа конфига
  UpdateConfigFetcher createFetcher(UpdateConfigType configType) {
    return UpdateConfigFetcher.customRaw(
      () => loadConfigFromAssets(configType.fileName),
    );
  }

  /// Загружает конфиг из assets
  Future<Map<String, dynamic>> loadConfigFromAssets(String fileName) async {
    final yamlString = await rootBundle.loadString('lib/configs/$fileName');
    final yaml = loadYaml(yamlString);

    if (yaml is YamlMap) {
      return _convertYamlMap(yaml);
    }

    throw ArgumentError('Invalid YAML format in $fileName');
  }

  /// Конвертирует YamlMap в Map<String, dynamic>
  Map<String, dynamic> _convertYamlMap(YamlMap yamlMap) {
    final map = <String, dynamic>{};

    yamlMap.nodes.forEach((key, value) {
      final keyString = (key as YamlScalar).value.toString();
      map[keyString] = _convertNode(value.value);
    });

    return map;
  }

  /// Рекурсивно конвертирует YamlNode в dynamic
  dynamic _convertNode(dynamic value) {
    if (value is YamlMap) {
      return _convertYamlMap(value);
    } else if (value is YamlList) {
      return value.map(_convertNode).toList();
    }

    return value;
  }
}
