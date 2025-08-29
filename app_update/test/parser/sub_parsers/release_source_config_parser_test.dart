import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../helpers/parser_test_helpers.dart';

void main() {
  group('ReleaseSourceConfigParser', () {
    const parser = ReleaseSourceConfigParser();

    test('Короткий синтаксис', () {
      const yamlStr = '''googlePlay''';
      final result = parser.parse(loadYaml(yamlStr));
      expect(result, isA<ReleaseSourceConfig>());
      expect(result?.sourceName.name, 'googlePlay'.toLowerCase());
      expect(result?.platforms, isNull);
      expect(result?.releaseOverride, isNull);
      expect(result?.contentRules, isNull);
      expect(result?.settingsRules, isNull);
      expect(result?.appSettingsRules, isNull);
      expect(result?.customParams, isNull);
    });

    test('Полный набор полей', () {
      const yamlStr = '''
        name: github
        platforms:
          - name: android
          - name: ios
        content:
          title: Title
        settings:
          should_show: true
        app_settings:
          app_status: active
        custom_params:
          custom_field: 42
      ''';
      final map = parseYamlToMap(yamlStr);
      final result = parser.parse(map);
      expect(result, isA<ReleaseSourceConfig>());
      expect(result?.sourceName.name, 'github'.toLowerCase());
      expect(result?.platforms?.length, 2);
      expect(result?.contentRules, isNotNull);
      expect(result?.settingsRules, isNotNull);
      expect(result?.appSettingsRules, isNotNull);
      expect(result?.customParams, containsPair('custom_field', 42));
    });

    test('Вложенный релиз', () {
      const yamlStr = '''
        name: github
        release_override:
          version: '1.2.3'
      ''';
      final map = parseYamlToMap(yamlStr);
      final result = parser.parse(map);
      expect(result?.releaseOverride?.version?.toString(), '1.2.3');
    });

    test('Ошибка при неверном типе', () {
      expect(() => parser.parse(123), throwsA(isA<ParseConfigException>()));
      expect(() => parser.parse([]), throwsA(isA<ParseConfigException>()));
    });

    test('Ошибка при невалидных платформах', () {
      final map = {
        'name': 'github',
        'platforms': 'android', // platforms должен быть List
      };
      expect(() => parser.parse(map), throwsA(isA<ParseConfigException>()));
    });

    test('null возвращает null', () {
      expect(parser.parse(null), isNull);
    });

    test('name обязательное поле', () {
      final map = {
        'platforms': ['android'],
      };

      expect(
        () => parser.parse(map),
        throwsA(
          isA<ParseConfigException>(),
        ),
      );
    });
  });
}
