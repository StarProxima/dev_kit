import 'dart:ui';

import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/coordinator_test_setup.dart';

void main() {
  group('UpdateConfigFetcherCoordinator - source fetchers', () {
    late CoordinatorTestSetup setup;

    setUpAll(CoordinatorTestSetup.setUpAll);

    setUp(() {
      setup = CoordinatorTestSetup();
      setup.setUp();
    });

    test(
      'выполняет source fetcher при shouldFetchSourceFetchers = true',
      () async {
        // Arrange
        const expectedConfig = UpdateConfig();
        when(() => setup.mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(setup.createSearchData());

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
        expect(result.last, expectedConfig);
        verify(() => setup.mockSourceFetcher.fetch(
              locale: const Locale('en'),
              packageInfo: setup.packageInfo,
            )).called(1);
      },
    );

    test(
      'пропускает source fetcher при shouldFetchSourceFetchers = false',
      () async {
        // Arrange
        when(() => setup.mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(setup.createSearchData());

        when(() => setup.mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);

        // Act
        final result = await setup.coordinator.fetch(
          fetchers: [setup.mockSourceFetcher],
          searchConfig: setup.baseSearchConfig,
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(1));
        verifyNever(() => setup.mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            ));
      },
    );

    test('пропускает source fetcher если SourceMatcher не матчит', () async {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData(
        sources: [UpdateSource.googlePlay], // Только GooglePlay
      ));

      when(() => setup.mockSourceFetcher.source)
          .thenReturn(UpdateSource.appStore); // AppStore не матчится

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(1));
      verifyNever(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          ));
    });

    test(
      'выполняет source fetcher если SourceMatcher матчит по платформе',
      () async {
        // Arrange
        const expectedConfig = UpdateConfig();
        when(() => setup.mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(setup.createSearchData(
          sources: [UpdateSource.googlePlay],
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
          searchConfig: const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [UpdateSource.googlePlay],
          ),
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(2));
        expect(result.last, expectedConfig);
      },
    );

    test(
      'пропускает source fetcher если платформа не поддерживается',
      () async {
        // Arrange
        when(() => setup.mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(setup.createSearchData());

        const iosOnlySource = UpdateSource.custom(
          UpdateSourceName.custom('ios_only'),
          platforms: [UpdatePlatform.ios], // Только iOS
        );

        when(() => setup.mockSourceFetcher.source).thenReturn(iosOnlySource);

        // Act
        final result = await setup.coordinator.fetch(
          fetchers: [setup.mockSourceFetcher],
          searchConfig: const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [iosOnlySource],
          ),
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(1)); // Только default, source пропущен
        verifyNever(() => setup.mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            ));
      },
    );

    test(
      'выполняет source fetcher с platforms = [any] (универсальный)',
      () async {
        // Arrange
        const expectedConfig = UpdateConfig();
        const universalSource = UpdateSource.custom(
          UpdateSourceName.custom('universal'),
          platforms: [UpdatePlatform.any], // Поддерживает все платформы
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
        expect(result, hasLength(2));
        expect(result.last, expectedConfig);
        verify(() => setup.mockSourceFetcher.fetch(
              locale: const Locale('en'),
              packageInfo: setup.packageInfo,
            )).called(1);
      },
    );

    test('обрабатывает множественные source fetchers', () async {
      // Arrange
      const config1 = UpdateConfig();
      const config2 = UpdateConfig();

      // Создаем универсальные источники
      const universalSource1 = UpdateSource.custom(
        UpdateSourceName.custom('universal1'),
        platforms: [UpdatePlatform.any],
      );
      const universalSource2 = UpdateSource.custom(
        UpdateSourceName.custom('universal2'),
        platforms: [UpdatePlatform.any],
      );

      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData(
        sources: [universalSource1, universalSource2],
      ));

      when(() => setup.mockSourceFetcher.source).thenReturn(universalSource1);
      when(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenAnswer((_) async => config1);

      when(() => setup.mockSourceFetcher2.source).thenReturn(universalSource2);
      when(() => setup.mockSourceFetcher2.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenAnswer((_) async => config2);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher, setup.mockSourceFetcher2],
        searchConfig: const UpdateSearchConfig(
          platform: UpdatePlatform.android,
          sources: [universalSource1, universalSource2],
        ),
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(3)); // default + 2 configs
      expect(result[1], config1);
      expect(result[2], config2);
    });

    test('обрабатывает UnimplementedError от source fetcher', () async {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      when(() => setup.mockSourceFetcher.source)
          .thenReturn(UpdateSource.googlePlay);
      when(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenThrow(UnimplementedError());

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(1)); // Только default
    });

    test('прокидывает другие ошибки от source fetcher', () {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      when(() => setup.mockSourceFetcher.source)
          .thenReturn(UpdateSource.googlePlay);
      when(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenThrow(Exception('Source fetcher error'));

      // Act & Assert
      expect(
        () => setup.coordinator.fetch(
          fetchers: [setup.mockSourceFetcher],
          searchConfig: setup.baseSearchConfig,
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
