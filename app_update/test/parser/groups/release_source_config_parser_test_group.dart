part of '../parser_test.dart';

void runReleaseSourceConfigParserTests() {
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
      expect(result?.customData, isNull);
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
        custom_field: 42
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<ReleaseSourceConfig>());
      expect(result?.sourceName.name, 'github'.toLowerCase());
      expect(result?.platforms?.length, 2);
      expect(result?.contentRules, isNotNull);
      expect(result?.settingsRules, isNotNull);
      expect(result?.appSettingsRules, isNotNull);
      expect(result?.customData, containsPair('custom_field', 42));
    });

    test('Вложенный релиз', () {
      const yamlStr = '''
        name: github
        release_override:
          version: '1.2.3'
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result?.releaseOverride?.version.toString(), '1.2.3');
    });

    test('Ошибка при неверном типе', () {
      expect(() => parser.parse(123), throwsA(isA<UpdateConfigException>()));
      expect(() => parser.parse([]), throwsA(isA<UpdateConfigException>()));
    });

    test('Ошибка при невалидных платформах', () {
      final map = {
        'name': 'github',
        'platforms': 'android', // platforms должен быть List
      };
      expect(() => parser.parse(map), throwsA(isA<UpdateConfigException>()));
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
          isA<UpdateConfigException>(),
        ),
      );
    });
  });
}
