import 'package:app_update/src/parser/common.dart';
import 'package:app_update/src/parser/sub_parsers/global_source_config_parser.dart';
import 'package:app_update/src/shared/models/global_source/global_source_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('GlobalSourceConfigParser', () {
    const parser = GlobalSourceConfigParser();

    test('Полный набор полей', () {
      const yamlStr = '''
        name: github
        platforms:
          - name: android
          - name: ios
        content:
          - locale_is: ru
            data:
              title: 'Заголовок'
        settings:
          - app_status_is: outdated
            data:
              can_skip: true
        app_settings:
          - version_is: any
            data:
              app_status: active
        custom_field: 42
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<GlobalSourceConfig>());
      expect(result?.sourceName.name, 'github');
      expect(result?.platforms?.length, 2);
      expect(result?.contentRules, isNotNull);
      expect(result?.settingsRules, isNotNull);
      expect(result?.appSettingsRules, isNotNull);
      expect(result?.customData, containsPair('custom_field', 42));
    });

    test('Ошибка при невалидных платформах', () {
      final map = {
        'name': 'github',
        'platforms': 'android', // platforms должен быть List
      };
      expect(() => parser.parse(map), throwsA(isA<UpdateConfigException>()));
    });

    test('Ошибка при неверном типе', () {
      expect(() => parser.parse(123), throwsA(isA<UpdateConfigException>()));
      expect(() => parser.parse([]), throwsA(isA<UpdateConfigException>()));
    });

    test('null возвращает null', () {
      expect(parser.parse(null), isNull);
    });
  });
}
