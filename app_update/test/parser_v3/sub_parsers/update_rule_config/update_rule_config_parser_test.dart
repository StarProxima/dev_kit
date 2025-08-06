import 'package:app_update/src/parser/sub_parsers/update_rule_config/update_rule_config.dart';
import 'package:app_update/src/parser/sub_parsers/update_rule_config/update_rule_config_parser.dart';
import 'package:app_update/src/parser/update_config_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('UpdateRuleConfigParser', () {
    const parser = UpdateRuleConfigParser();

    test('Базовое правило с data', () {
      const yamlStr = '''
        app_statuses: outdated
        data:
          title: "Заголовок"
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse<Map>(map, dataParser: (v) => v);
      expect(result, isA<UpdateRuleConfig>());
      expect(result?.appStatuses.first.name, 'outdated');
      expect(result?.data['title'], 'Заголовок');
    });

    test('Массивы значений', () {
      const yamlStr = '''
        app_statuses: [outdated, active]
        locales: [ru, en]
        view_targets: [card, dialog]
        versions: [">=1.0.0", "<2.0.0"]
        sources: [googlePlay, appStore]
        data:
          title: test
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map, dataParser: (v) => v);
      expect(result?.appStatuses.length, 2);
      expect(result?.locales.length, 2);
      expect(result?.viewTargets.length, 2);
      expect(result?.versions.length, 2);
      expect(result?.sources.length, 2);
    });

    test('null возвращает null', () {
      final result = parser.parse(null, dataParser: (v) => v);
      expect(result, isNull);
    });

    test('Ошибка при неверном типе', () {
      expect(() => parser.parse(123, dataParser: (v) => v), throwsA(isA<UpdateConfigException>()));
      expect(() => parser.parse([], dataParser: (v) => v), throwsA(isA<UpdateConfigException>()));
    });

    test('customData содержит неиспользованные поля', () {
      const yamlStr = '''
        app_statuses: outdated
        custom_field: 42
        data:
          title: test
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map, dataParser: (v) => v);
      expect(result?.customData, containsPair('custom_field', 42));
    });
  });
}
