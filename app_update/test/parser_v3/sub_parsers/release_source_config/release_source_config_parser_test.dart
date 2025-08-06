import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';
import 'package:app_update/src/parser/sub_parsers/release_source_config/release_source_config_parser.dart';
import 'package:app_update/src/parser/sub_parsers/release_source_config/release_source_config.dart';
import 'package:app_update/src/parser/update_config_exception.dart';

void main() {
  group('ReleaseSourceConfigParser', () {
    const parser = ReleaseSourceConfigParser();

    test('Короткий синтаксис', () {
      const yamlStr = '''googlePlay''';
      final result = parser.parse(loadYaml(yamlStr));
      expect(result, isA<ReleaseSourceConfig>());
      expect(result?.source?.name, 'googlePlay'.toLowerCase());
      expect(result?.url, isNull);
      expect(result?.platforms, isNull);
      expect(result?.releaseOverride, isNull);
      expect(result?.customData, isNull);
    });

    test('Полный набор полей', () {
      const yamlStr = '''
        name: github
        url: 'https://github.com/user/repo/releases'
        platforms:
          - name: android
          - name: ios
        custom_field: 42
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<ReleaseSourceConfig>());
      expect(result?.source?.name, 'github'.toLowerCase());
      expect(result?.url.toString(), 'https://github.com/user/repo/releases');
      expect(result?.platforms?.length, 2);
      expect(result?.customData, containsPair('custom_field', 42));
    });

    test('Вложенный релиз', () {
      const yamlStr = '''
        name: github
        release:
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
  });
}
