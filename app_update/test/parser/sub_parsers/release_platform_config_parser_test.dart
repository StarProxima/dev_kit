import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../helpers/parser_test_helpers.dart';

void main() {
  group('ReleasePlatformConfigParser', () {
    const parser = ReleasePlatformConfigParser();

    test('Короткий синтаксис', () {
      const yamlStr = '''android''';
      final result = parser.parse(loadYaml(yamlStr));
      expect(result, isA<ReleasePlatformConfig>());
      expect(result?.platformName.name, 'android');
      expect(result?.releaseOverride, isNull);
      expect(result?.contentRules, isNull);
      expect(result?.settingsRules, isNull);
      expect(result?.appSettingsRules, isNull);
      expect(result?.customParams, isNull);
    });

    test('Полный набор полей', () {
      const yamlStr = '''
        name: ios
        release_override:
          version: '1.2.3'
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
      expect(result, isA<ReleasePlatformConfig>());
      expect(result?.platformName.name, 'ios');
      expect(result?.releaseOverride?.version?.toString(), '1.2.3');
      expect(result?.contentRules, isNotNull);
      expect(result?.settingsRules, isNotNull);
      expect(result?.appSettingsRules, isNotNull);
      expect(result?.customParams, containsPair('custom_field', 42));
    });

    test('Ошибка при неверном типе', () {
      expect(() => parser.parse(123), throwsA(isA<ParseConfigException>()));
      expect(() => parser.parse([]), throwsA(isA<ParseConfigException>()));
    });

    test('null возвращает null', () {
      expect(parser.parse(null), isNull);
    });
  });
}
