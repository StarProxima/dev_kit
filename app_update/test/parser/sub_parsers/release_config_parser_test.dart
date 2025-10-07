// ignore_for_file: avoid-unsafe-collection-methods, prefer-first, prefer-moving-to-variable

import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/parser_test_helpers.dart';

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
          custom_field: 123
      ''';
      final map = parseYamlToMap(yamlStr);
      final result = parser.parse(map, isDebug: true);
      expect(result, isA<ReleaseConfig>());
      expect(result?.version.toString(), '1.2.3+4');
      expect(result?.date.year, 2024);
      expect(result?.sources, isNotNull);
      expect(result?.sources?.length, 2);
      expect(result?.sources?[0].sourceName.name, 'googlePlay'.toLowerCase());
      expect(result?.sources?[0].platforms, isNotNull);
      expect(result?.sources?[0].platforms?[0].platformName.name, 'android');
      expect(
        result?.sources?[0].platforms?[0].releaseOverride?.version?.toString(),
        '1.2.4',
      );
      expect(result?.sources?[1].sourceName.name, 'appStore'.toLowerCase());
      expect(result?.contentRules, isNotNull);
      expect(result?.settingsRules, isNotNull);
      expect(result?.appSettingsRules, isNotNull);
      expect(result?.customParams, containsPair('custom_field', 123));
    });

    test('Парсинг короткого синтаксиса источников', () {
      const yamlStr = '''
        version: '0.1.0'
        date: '2024-08-24 15:35:00'
        sources:
          - googlePlay
          - appStore
      ''';
      final map = parseYamlToMap(yamlStr);
      final result = parser.parse(map, isDebug: true);
      expect(result, isA<ReleaseConfig>());
      expect(result?.sources?.length, 2);
      expect(result?.sources?[0].sourceName.name, 'googlePlay'.toLowerCase());
      expect(result?.sources?[1].sourceName.name, 'appStore'.toLowerCase());
      expect(result?.date, equals(DateTime(2024, 8, 24, 15, 35)));
    });

    test('Парсинг вложенного релиза в источнике', () {
      const yamlStr = '''
        version: '0.2.0'
        date: '2024-08-24 15:35:00'
        sources:
          - name: github
            release_override:
              version: '0.2.1'
              date: '2025-10-10 12:00:00'
      ''';
      final map = parseYamlToMap(yamlStr);
      final result = parser.parse(map, isDebug: true);
      expect(result, isA<ReleaseConfig>());
      expect(result?.sources?[0].releaseOverride?.version?.toString(), '0.2.1');
      expect(
        result?.sources?[0].releaseOverride?.date,
        equals(DateTime(2025, 10, 10, 12)),
      );
    });

    test('Парсинг null возвращает null', () {
      final result = parser.parse(null, isDebug: true);
      expect(result, isNull);
    });

    test('Ошибка при неверном типе входных данных', () {
      expect(
        () => parser.parse('not a map', isDebug: true),
        throwsA(isA<ParseConfigException>()),
      );
      expect(
        () => parser.parse(123, isDebug: true),
        throwsA(isA<ParseConfigException>()),
      );
      expect(
        () => parser.parse([], isDebug: true),
        throwsA(isA<ParseConfigException>()),
      );
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
      expect(
        () => parser.parse(
          map,
          isDebug: true,
        ),
        throwsA(isA<ParseConfigException>()),
      );
    });
  });
}
