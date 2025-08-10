import 'package:app_update/src/parser/common.dart';
import 'package:app_update/src/parser/sub_parsers/release_config_parser.dart';
import 'package:app_update/src/shared/models/release/release_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('ReleaseConfigParser', () {
    const parser = ReleaseConfigParser();

    test('Парсинг полного набора полей с вложенными источниками', () {
      const yamlStr = '''
        version: '1.2.3+4'
        date: '2024-08-24 15:35:00'
        sources:
          - name: googlePlay
            platforms:
              - name: android
                release_override:
                  version: '1.2.4'
          - appStore
        content:
          - locales: ru
            data:
              title: 'Заголовок'
        settings:
          - app_statuses: outdated
            data:
              can_skip: true
        app_settings:
          - versions: any
            data:
              app_status: active
        custom_field: 123
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<ReleaseConfig>());
      expect(result?.version.toString(), '1.2.3+4');
      expect(result?.date?.year, 2024);
      expect(result?.sources, isNotNull);
      expect(result?.sources?.length, 2);
      expect(result?.sources?[0].sourceName?.name, 'googlePlay'.toLowerCase());
      expect(result?.sources?[0].platforms, isNotNull);
      expect(result?.sources?[0].platforms?[0].platformName.name, 'android');
      expect(result?.sources?[0].platforms?[0].releaseOverride?.version.toString(), '1.2.4');
      expect(result?.sources?[1].sourceName?.name, 'appStore'.toLowerCase());
      expect(result?.contentRules, isNotNull);
      expect(result?.settingsRules, isNotNull);
      expect(result?.appSettingsRules, isNotNull);
      expect(result?.customData, containsPair('custom_field', 123));
    });

    test('Парсинг короткого синтаксиса источников', () {
      const yamlStr = '''
        version: '0.1.0'
        sources:
          - googlePlay
          - appStore
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<ReleaseConfig>());
      expect(result?.sources?.length, 2);
      expect(result?.sources?[0].sourceName?.name, 'googlePlay'.toLowerCase());
      expect(result?.sources?[1].sourceName?.name, 'appStore'.toLowerCase());
    });

    test('Парсинг вложенного релиза в источнике', () {
      const yamlStr = '''
        version: '0.2.0'
        sources:
          - name: github
            release_override:
              version: '0.2.1'
      ''';
      final map = Map<String, dynamic>.from(loadYaml(yamlStr));
      final result = parser.parse(map);
      expect(result, isA<ReleaseConfig>());
      expect(result?.sources?[0].releaseOverride?.version.toString(), '0.2.1');
    });

    test('Парсинг null возвращает null', () {
      final result = parser.parse(null);
      expect(result, isNull);
    });

    test('Ошибка при неверном типе входных данных', () {
      expect(() => parser.parse('not a map'), throwsA(isA<UpdateConfigException>()));
      expect(() => parser.parse(123), throwsA(isA<UpdateConfigException>()));
      expect(() => parser.parse([]), throwsA(isA<UpdateConfigException>()));
    });

    test('Ошибка при невалидных вложенных структурах', () {
      // Некорректный platforms
      final map = {
        'version': '1.0.0',
        'sources': [
          {
            'name': 'googlePlay',
            'platforms': 'android', // platforms должен быть List
          },
        ],
      };
      expect(() => parser.parse(map), throwsA(isA<UpdateConfigException>()));
    });
  });
}
