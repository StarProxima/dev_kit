// ignore_for_file: avoid-type-casts, prefer-static-class

import 'package:app_update/app_update.dart';
import 'package:yaml/yaml.dart';

Map<String, dynamic> parseYamlToMap(String yamlStr) {
  final map = (loadYaml(yamlStr) as YamlMap).toMap();

  return map;
}
