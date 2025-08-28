import 'dart:ui';

import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/coordinator_test_setup.dart';

void main() {
  group('UpdateConfigFetcherCoordinator - edge cases', () {
    late CoordinatorTestSetup setup;

    setUpAll(CoordinatorTestSetup.setUpAll);

    setUp(() {
      setup = CoordinatorTestSetup();
      setup.setUp();
    });

    test('обрабатывает источник с пустым списком platforms', () async {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      const sourceWithEmptyPlatforms = UpdateSource.custom(
        UpdateSourceName.custom('empty_platforms'),
        platforms: [], // Пустой список платформ
      );

      when(() => setup.mockSourceFetcher.source)
          .thenReturn(sourceWithEmptyPlatforms);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher],
        searchConfig: const UpdateSearchConfig(
          platform: UpdatePlatform.android,
          sources: [sourceWithEmptyPlatforms],
        ),
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(1)); // Только default, source пропускается
      verifyNever(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          ));
    });

    test('обрабатывает источник с null platforms (универсальный)', () async {
      // Arrange
      const expectedConfig = UpdateConfig();
      const universalSource = UpdateSource.custom(
        UpdateSourceName.custom('universal'),
        platforms: [UpdatePlatform.any], // any = поддерживает все платформы
      );

      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData(
        sources: [universalSource],
      ));

      when(() => setup.mockSourceFetcher.source).thenReturn(universalSource);
      when(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenAnswer((_) async => expectedConfig);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher],
        searchConfig: const UpdateSearchConfig(
          platform: UpdatePlatform.android,
          sources: [universalSource],
        ),
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(2)); // default + universal source
      expect(result.last, expectedConfig);
      verify(() => setup.mockSourceFetcher.fetch(
            locale: const Locale('en'),
            packageInfo: setup.packageInfo,
          )).called(1);
    });

    test('обрабатывает пустой список источников в searchConfig', () async {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData(
        sources: [], // Пустой список источников
      ));

      when(() => setup.mockSourceFetcher.source)
          .thenReturn(UpdateSource.googlePlay);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher],
        searchConfig: const UpdateSearchConfig(
          platform: UpdatePlatform.android,
          sources: [], // Пустой список
        ),
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(1)); // Только default
      verifyNever(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          ));
    });

    test('обрабатывает null locale правильно', () async {
      // Arrange
      const expectedConfig = UpdateConfig();
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData(
        locale: const UpdateLocale(null), // null locale
      ));

      when(() => setup.mockSourceFetcher.source)
          .thenReturn(UpdateSource.googlePlay);
      when(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenAnswer((_) async => expectedConfig);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(2));
      // Должен использовать дефолтный locale EN
      verify(() => setup.mockSourceFetcher.fetch(
            locale: const Locale('en'),
            packageInfo: setup.packageInfo,
          )).called(1);
    });

    test('обрабатывает большое количество fetchers', () async {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      final fetchers = <UpdateConfigFetcher>[];
      const fetcherCount = 50;

      // Создаем много regular fetchers
      for (int i = 0; i < fetcherCount; i++) {
        final config = UpdateConfig(
          releases: [setup.createReleaseConfig('1.0.$i')],
          customParams: {'index': i},
        );
        fetchers.add(setup.createSimpleFetcher(config));
      }

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: fetchers,
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: false,
        shouldFetchFerchers: true,
      );

      // Assert
      expect(result, hasLength(fetcherCount + 1)); // default + все fetchers

      // Проверяем, что все конфигурации на месте (пропускаем default config)
      final nonDefaultConfigs = result.skip(1);
      int expectedIndex = 0;
      for (final config in nonDefaultConfigs) {
        expect(config.customParams?['index'], expectedIndex);
        expectedIndex++;
      }
    });

    test(
      'обрабатывает смешанный список с частично невалидными fetchers',
      () {
        // Arrange
        when(() => setup.mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(setup.createSearchData());

        const validConfig = UpdateConfig(customParams: {'valid': true});
        final validFetcher = setup.createSimpleFetcher(validConfig);

        // Fetcher который бросает UnimplementedError
        final unimplementedFetcher = UpdateConfigFetcher.custom(
          () => throw UnimplementedError('Not implemented'),
        );

        when(() => setup.mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);
        when(() => setup.mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenThrow(UnimplementedError('Source not implemented'));

        // Act & Assert - должен прогалкнуть исключение от regular fetcher
        expect(
          () => setup.coordinator.fetch(
            fetchers: [
              setup
                  .mockSourceFetcher, // UnimplementedError - будет проигнорирован
              validFetcher, // Валидный
              unimplementedFetcher, // UnimplementedError - не будет проигнорирован для regular fetcher
            ],
            searchConfig: setup.baseSearchConfig,
            packageInfo: setup.packageInfo,
            shouldFetchSourceFetchers: true,
            shouldFetchFerchers: true,
          ),
          throwsA(isA<UnimplementedError>()),
        );
      },
    );

    test('обрабатывает кастомные источники с одинаковыми именами', () async {
      // Arrange
      const config1 = UpdateConfig(customParams: {'source': 1});
      const config2 = UpdateConfig(customParams: {'source': 2});

      const customSource1 = UpdateSource.custom(
        UpdateSourceName.custom('custom'),
        platforms: [UpdatePlatform.android],
      );
      const customSource2 = UpdateSource.custom(
        UpdateSourceName.custom('custom'), // Такое же имя!
        platforms: [UpdatePlatform.android],
      );

      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData(
        sources: [customSource1, customSource2],
      ));

      when(() => setup.mockSourceFetcher.source).thenReturn(customSource1);
      when(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenAnswer((_) async => config1);

      when(() => setup.mockSourceFetcher2.source).thenReturn(customSource2);
      when(() => setup.mockSourceFetcher2.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenAnswer((_) async => config2);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher, setup.mockSourceFetcher2],
        searchConfig: const UpdateSearchConfig(
          platform: UpdatePlatform.android,
          sources: [customSource1, customSource2],
        ),
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(3)); // default + 2 configs
      expect(result[1].customParams?['source'], 1);
      expect(result[2].customParams?['source'], 2);
    });

    test('правильно обрабатывает очень длинные списки источников', () async {
      // Arrange
      final sources = <UpdateSource>[];
      const sourceCount = 100;

      for (int i = 0; i < sourceCount; i++) {
        sources.add(UpdateSource.custom(
          UpdateSourceName.custom('source_$i'),
          platforms: i.isEven ? [UpdatePlatform.android] : [UpdatePlatform.ios],
        ));
      }

      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData(
        sources: sources,
      ));

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [],
        searchConfig: UpdateSearchConfig(
          platform: UpdatePlatform.android,
          sources: sources,
        ),
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(1)); // Только default (нет подходящих fetchers)
    });
  });
}
