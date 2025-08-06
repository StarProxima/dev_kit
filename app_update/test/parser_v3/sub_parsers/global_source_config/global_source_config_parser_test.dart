import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import 'package:app_update/src/parser/sub_parsers/global_source_config/global_source_config_parser.dart';
import 'package:app_update/src/parser/sub_parsers/global_source_config/global_source_config.dart';
import 'package:app_update/src/parser/update_config_exception.dart';

void main() {
  group('GlobalSourceConfigParser', () {
    const parser = GlobalSourceConfigParser();

    test('Полный набор полей', () {
      const yamlStr = '''
        name: github
        url: 'https://github.com/user/repo/releases'
        platforms:
          - name: android
          - name: ios
        content_rules:
          - locales: ru
            data:
              title: 'Заголовок'
        settings_rules:
          - app_statuses: outdated
            data:
              can_skip: true
        app_status_rules:
          - version: any
            data:
              app_status: active
        custom_field: 42
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<GlobalSourceConfig>());
      expect(result?.source?.name, 'github');
      expect(result?.url.toString(), 'https://github.com/user/repo/releases');
      expect(result?.platforms?.length, 2);
      expect(result?.contentRules, isNotNull);
      expect(result?.settingsRules, isNotNull);
      expect(result?.appStatusRules, isNotNull);
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
