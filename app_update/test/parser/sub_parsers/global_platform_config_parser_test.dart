import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../helpers/parser_test_helpers.dart';

void main() {
  group('GlobalPlatformConfigParser', () {
    const parser = GlobalPlatformConfigParser();

    test('Короткий синтаксис', () {
      const yamlStr = '''android''';
      final result = parser.parse(loadYaml(yamlStr), isDebug: true);
      expect(result, isA<GlobalPlatformConfig>());
      expect(result?.platformName.name, 'android');
      expect(result?.contentRules, isNull);
      expect(result?.settingsRules, isNull);
      expect(result?.appSettingsRules, isNull);
      expect(result?.customParams, isNull);
    });

    test('Полный набор полей (rules)', () {
      const yamlStr = '''
        name: ios
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
      final result = parser.parse(map, isDebug: true);
      expect(result, isA<GlobalPlatformConfig>());
      expect(result?.platformName.name, 'ios');
      expect(result?.contentRules, isNotNull);
      expect(result?.settingsRules, isNotNull);
      expect(result?.appSettingsRules, isNotNull);
      expect(result?.customParams, containsPair('custom_field', 42));
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
