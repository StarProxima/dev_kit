import 'dart:io';

import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;

import '../helpers/coordinator_test_setup.dart';

void main() {
  group('UpdateConfigFetcherCoordinator - regular fetchers', () {
    late CoordinatorTestSetup setup;

    setUpAll(CoordinatorTestSetup.setUpAll);

    setUp(() {
      setup = CoordinatorTestSetup();
      setup.setUp();
    });

    test('выполняет regular fetcher при shouldFetchFetchers = true', () async {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      final expectedConfig = UpdateConfig(
        releases: [setup.createReleaseConfig('2.0.0')],
      );
      final regularFetcher = setup.createSimpleFetcher(expectedConfig);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [regularFetcher],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: false,
        shouldFetchFetchers: true,
      );

      // Assert
      expect(result, hasLength(2));
      expect(result.last, expectedConfig);
    });

    test(
      'пропускает regular fetcher при shouldFetchFetchers = false',
      () async {
        // Arrange
        when(() => setup.mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(setup.createSearchData());

        final expectedConfig = UpdateConfig(
          releases: [setup.createReleaseConfig('2.0.0')],
        );
        final regularFetcher = setup.createSimpleFetcher(expectedConfig);

        // Act
        final result = await setup.coordinator.fetch(
          fetchers: [regularFetcher],
          searchConfig: setup.baseSearchConfig,
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFetchers: false,
        );

        // Assert
        expect(result, hasLength(1)); // Только default
      },
    );

    test('обрабатывает множественные regular fetchers', () async {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      final config1 = UpdateConfig(
        releases: [setup.createReleaseConfig('1.0.0')],
      );
      final config2 = UpdateConfig(
        releases: [setup.createReleaseConfig('2.0.0')],
      );
      final config3 = UpdateConfig(
        releases: [setup.createReleaseConfig('3.0.0')],
      );

      final fetcher1 = setup.createSimpleFetcher(config1);
      final fetcher2 = setup.createSimpleFetcher(config2);
      final fetcher3 = setup.createSimpleFetcher(config3);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [fetcher1, fetcher2, fetcher3],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: false,
        shouldFetchFetchers: true,
      );

      // Assert
      expect(result, hasLength(4)); // default + 3 configs
      expect(result[1], config1);
      expect(result[2], config2);
      expect(result[3], config3);
    });

    test('обрабатывает custom fetcher', () async {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      const expectedConfig = UpdateConfig(
        customParams: {'custom_field': 'custom_value'},
      );

      final customFetcher = UpdateConfigFetcher.custom(() => expectedConfig);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [customFetcher],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: false,
        shouldFetchFetchers: true,
      );

      // Assert
      expect(result, hasLength(2));
      expect(result.last, expectedConfig);
      expect(result.last.customParams?['custom_field'], 'custom_value');
    });

    test('обрабатывает fetcher из файла', () async {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      // Создаем временный файл с YAML
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final configFile = File(path.join(tempDir.path, 'test_config.yaml'));
      await configFile.writeAsString('''
releases:
  - version: 1.5.0
    date: "2024-01-01T00:00:00Z"
    content:
      release_notes: Test release notes
''');

      final fileFetcher = UpdateConfigFetcher.byFile(configFile);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [fileFetcher],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: false,
        shouldFetchFetchers: true,
      );

      // Assert
      expect(result, hasLength(2));
      expect(result.last.releases, hasLength(1));
      expect(result.last.releases.first.version.toString(), '1.5.0');

      // Cleanup
      await tempDir.delete(recursive: true);
    });

    test('прокидывает ошибки от regular fetcher', () {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      final errorFetcher = UpdateConfigFetcher.custom(
        () => throw Exception('Regular fetcher error'),
      );

      // Act & Assert
      expect(
        () => setup.coordinator.fetch(
          fetchers: [errorFetcher],
          searchConfig: setup.baseSearchConfig,
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFetchers: true,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('обрабатывает fetcher с некорректными данными', () async {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      // Создаем временный файл с некорректным YAML
      final tempDir = await Directory.systemTemp.createTemp('test_');
      final configFile = File(path.join(tempDir.path, 'bad_config.yaml'));
      await configFile.writeAsString('''
invalid_yaml: [unclosed bracket
''');

      final fileFetcher = UpdateConfigFetcher.byFile(configFile);

      // Act & Assert
      expect(
        () => setup.coordinator.fetch(
          fetchers: [fileFetcher],
          searchConfig: setup.baseSearchConfig,
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFetchers: true,
        ),
        throwsA(isA<Exception>()),
      );

      // Cleanup
      await tempDir.delete(recursive: true);
    });

    test('смешанные source и regular fetchers', () async {
      // Arrange
      const sourceConfig = UpdateConfig();
      final regularConfig = UpdateConfig(
        releases: [setup.createReleaseConfig('1.0.0')],
      );

      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      when(() => setup.mockSourceFetcher.source)
          .thenReturn(UpdateSource.googlePlay);
      when(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenAnswer((_) async => sourceConfig);

      final regularFetcher = setup.createSimpleFetcher(regularConfig);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher, regularFetcher],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFetchers: true,
      );

      // Assert
      expect(result,
          hasLength(4)); // default + fetchSourceAppUrl + fetch + regular
      // result[1] - fetchSourceAppUrl (пустой)
      // result[2] - fetch (sourceConfig)
      // result[3] - regular
    });
  });
}
