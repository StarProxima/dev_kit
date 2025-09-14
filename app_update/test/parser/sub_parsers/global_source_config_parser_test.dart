import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/parser_test_helpers.dart';

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
          - when:
              locale_is: ru
            data:
              title: 'Заголовок'
        settings:
          - when:
              app_status_is: outdated
            data:
              can_skip: true
        app_settings:
          - when:
              app_version_is: any
            data:
              app_status: active
        custom_params:
          custom_field: 42
      ''';
      final map = parseYamlToMap(yamlStr);
      final result = parser.parse(map, isDebug: true);
      expect(result, isA<GlobalSourceConfig>());
      expect(result?.sourceName.name, 'github');
      expect(result?.platforms?.length, 2);
      expect(result?.contentRules, isNotNull);
      expect(result?.settingsRules, isNotNull);
      expect(result?.appSettingsRules, isNotNull);
      expect(result?.customParams, containsPair('custom_field', 42));
    });

    test('Ошибка при невалидных платформах', () {
      final map = {
        'name': 'github',
        'platforms': 'android', // platforms должен быть List
      };
      expect(() => parser.parse(map, isDebug: true),
          throwsA(isA<ParseConfigException>()));
    });

    test('Ошибка при неверном типе', () {
      expect(() => parser.parse(123, isDebug: true),
          throwsA(isA<ParseConfigException>()));
      expect(() => parser.parse([], isDebug: true),
          throwsA(isA<ParseConfigException>()));
    });

    test('null возвращает null', () {
      expect(parser.parse(null, isDebug: true), isNull);
    });
  });
}
