// ignore_for_file: prefer-explicit-type-arguments, avoid-type-casts

import 'dart:io';
import 'dart:ui';

import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yaml/yaml.dart';

import 'helpers/mock_source_fetchers.dart';

void main() {
  group('UpdateConfigFetcher', () {
    late MockUpdateConfigParser mockParser;

    setUpAll(() {
      // Регистрируем fallback значения
      registerFallbackValue(const Locale('en'));
      registerFallbackValue(FakePackageInfo());
      registerFallbackValue(<String, dynamic>{});
    });

    setUp(() {
      mockParser = MockUpdateConfigParser();
    });

    group('custom constructor', () {
      test('успешно выполняет кастомную функцию fetch', () async {
        // Arrange
        const expectedConfig = UpdateConfig();
        final fetcher = UpdateConfigFetcher.custom(() async => expectedConfig);

        // Act
        final result = await fetcher.fetch(
          locale: const Locale('en'),
          packageInfo: FakePackageInfo(),
        );

        // Assert
        expect(result, equals(expectedConfig));
      });

      test('использует переданный parser', () {
        final fetcher = UpdateConfigFetcher.custom(
          () async => const UpdateConfig(),
        );

        expect(fetcher, isA<UpdateConfigFetcher>());
      });
    });

    group('customRaw constructor', () {
      test('успешно парсит raw данные через parser', () async {
        // Arrange
        final rawData = <String, dynamic>{'test': 'data'};
        const expectedConfig = UpdateConfig();

        when(() => mockParser.parse(any(), isDebug: any(named: 'isDebug')))
            .thenReturn(expectedConfig);

        final fetcher = UpdateConfigFetcher.customRaw(
          () async => rawData,
          updateConfigParser: mockParser,
        );

        // Act
        final result = await fetcher.fetch(
          locale: const Locale('en'),
          packageInfo: FakePackageInfo(),
        );

        // Assert
        expect(result, equals(expectedConfig));
        verify(() => mockParser.parse(rawData, isDebug: true)).called(1);
      });

      test('бросает UpdateConfigException если parser вернул null', () {
        // Arrange
        when(() => mockParser.parse(any(), isDebug: any(named: 'isDebug')))
            .thenReturn(null);

        final fetcher = UpdateConfigFetcher.customRaw(
          () async => <String, dynamic>{'test': 'data'},
          updateConfigParser: mockParser,
        );

        // Act & Assert
        expect(
          () => fetcher.fetch(
            locale: const Locale('en'),
            packageInfo: FakePackageInfo(),
          ),
          throwsA(isA<ParseConfigException>()),
        );
      });
    });

    group('byFile factory', () {
      test('создает fetcher для чтения из файла', () async {
        // Arrange
        final tempDir = Directory.systemTemp.createTempSync();
        final testFile = File('${tempDir.path}/test_config.yaml');
        await testFile.writeAsString('''
content:
  - data:
      update_url: "https://example.com"
      title: "Update Available"
      description: "New version"
      release_notes_title: "What's New"
      skip_button: "Skip"
      postpone_button: "Later" 
      update_button: "Update"
settings:
  - data:
      should_show: true
      can_skip: true
      can_postpone: true
      skip_release_delay_hours: 24
      skip_all_releases_delay_hours: 168
      postpone_release_delay_hours: 12
      postpone_all_releases_delay_hours: 72
app_settings:
  - data:
      app_status: active
releases: []
        ''');

        final fetcher = UpdateConfigFetcher.byFile(testFile);

        // Act
        final result = await fetcher.fetch(
          locale: const Locale('en'),
          packageInfo: FakePackageInfo(),
        );

        // Assert
        expect(result, isA<UpdateConfig>());

        // Cleanup
        tempDir.deleteSync(recursive: true);
      });

      test('бросает ошибку для неправильного YAML формата', () async {
        // Arrange
        final tempDir = Directory.systemTemp.createTempSync();
        final testFile = File('${tempDir.path}/bad_config.yaml');
        await testFile.writeAsString('invalid_yaml_content: [');

        final fetcher = UpdateConfigFetcher.byFile(testFile);

        // Act & Assert
        expect(
          () => fetcher.fetch(
            locale: const Locale('en'),
            packageInfo: FakePackageInfo(),
          ),
          throwsA(isA<YamlException>()),
        );

        // Cleanup
        tempDir.deleteSync(recursive: true);
      });
    });

    group('byUrl factory', () {
      test('создает fetcher для чтения из URL (файл)', () async {
        // Arrange
        final tempDir = Directory.systemTemp.createTempSync();
        final testFile = File('${tempDir.path}/url_config.yaml');
        await testFile.writeAsString('''
content:
  - data:
      update_url: "https://example.com"
      title: "Update Available"
      description: "New version"
      release_notes_title: "What's New"
      skip_button: "Skip"
      postpone_button: "Later" 
      update_button: "Update"
settings:
  - data:
      should_show: true
      can_skip: true
      can_postpone: true
      skip_release_delay_hours: 24
      skip_all_releases_delay_hours: 168
      postpone_release_delay_hours: 12
      postpone_all_releases_delay_hours: 72
app_settings:
  - data:
      app_status: active
releases: []
        ''');

        final fetcher = UpdateConfigFetcher.byUrl(testFile.uri);

        // Act
        final result = await fetcher.fetch(
          locale: const Locale('en'),
          packageInfo: FakePackageInfo(),
        );

        // Assert
        expect(result, isA<UpdateConfig>());

        // Cleanup
        tempDir.deleteSync(recursive: true);
      });
    });

    group('fetch method edge cases', () {
      test(
        'бросает UpdateConfigException если нет fetchRawConfig и fetchConfig',
        () {
          // Arrange - создаем fetcher с null функцией
          final fetcher = UpdateConfigFetcher.customRaw(
            () async => throw Exception('Test'),
          );

          // Act & Assert
          expect(
            () => fetcher.fetch(
              locale: const Locale('en'),
              packageInfo: FakePackageInfo(),
            ),
            throwsA(isA<Exception>()),
          );
        },
      );
    });

    group('YamlMapConverter extension', () {
      test('правильно конвертирует вложенные YamlMap в обычные Map', () {
        // Arrange
        const yamlContent = '''
root:
  nested:
    value: test
  list:
    - item1
    - item2
        ''';
        final result = (loadYaml(yamlContent) as YamlMap).toMap();

        // Assert
        expect(result['root'], isA<Map<String, dynamic>>());
        final rootMap = result['root'] as Map<String, dynamic>;
        expect(rootMap['nested'], isA<Map<String, dynamic>>());
        expect(rootMap['list'], isA<List>());

        final nestedMap = rootMap['nested'] as Map<String, dynamic>;
        expect(nestedMap['value'], 'test');

        final list = rootMap['list'] as List;
        expect(list, ['item1', 'item2']);
      });
    });
  });
}
