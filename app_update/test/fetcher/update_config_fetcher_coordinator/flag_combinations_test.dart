import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/coordinator_test_setup.dart';

void main() {
  group('UpdateConfigFetcherCoordinator - комбинации флагов', () {
    late CoordinatorTestSetup setup;

    setUpAll(CoordinatorTestSetup.setUpAll);

    setUp(() {
      setup = CoordinatorTestSetup();
      setup.setUp();

      // Base setup для всех тестов
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      when(() => setup.mockSourceFetcher.source)
          .thenReturn(UpdateSource.googlePlay);
      when(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenAnswer((_) async => const UpdateConfig());
    });

    test('shouldFetchSourceFetchers=true, shouldFetchFerchers=true', () async {
      // Arrange
      final regularConfig = UpdateConfig(
        releases: [setup.createReleaseConfig('1.0.0')],
      );
      final regularFetcher = setup.createSimpleFetcher(regularConfig);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher, regularFetcher],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: true,
      );

      // Assert
      expect(result, hasLength(3)); // default + source + regular
      verify(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).called(1);
    });

    test(
      'shouldFetchSourceFetchers=false, shouldFetchFerchers=true',
      () async {
        // Arrange
        final regularConfig = UpdateConfig(
          releases: [setup.createReleaseConfig('1.0.0')],
        );
        final regularFetcher = setup.createSimpleFetcher(regularConfig);

        // Act
        final result = await setup.coordinator.fetch(
          fetchers: [setup.mockSourceFetcher, regularFetcher],
          searchConfig: setup.baseSearchConfig,
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFerchers: true,
        );

        // Assert
        expect(result, hasLength(2)); // default + regular
        verifyNever(() => setup.mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            ));
      },
    );

    test(
      'shouldFetchSourceFetchers=true, shouldFetchFerchers=false',
      () async {
        // Arrange
        final regularConfig = UpdateConfig(
          releases: [setup.createReleaseConfig('1.0.0')],
        );
        final regularFetcher = setup.createSimpleFetcher(regularConfig);

        // Act
        final result = await setup.coordinator.fetch(
          fetchers: [setup.mockSourceFetcher, regularFetcher],
          searchConfig: setup.baseSearchConfig,
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(2)); // default + source
        verify(() => setup.mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).called(1);
      },
    );

    test(
      'shouldFetchSourceFetchers=false, shouldFetchFerchers=false',
      () async {
        // Arrange
        final regularConfig = UpdateConfig(
          releases: [setup.createReleaseConfig('1.0.0')],
        );
        final regularFetcher = setup.createSimpleFetcher(regularConfig);

        // Act
        final result = await setup.coordinator.fetch(
          fetchers: [setup.mockSourceFetcher, regularFetcher],
          searchConfig: setup.baseSearchConfig,
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(1)); // Только default
        verifyNever(() => setup.mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            ));
      },
    );

    test('пустой список fetchers с любыми флагами', () async {
      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: true,
      );

      // Assert
      expect(result, hasLength(1)); // Только default
    });

    test('только source fetchers с shouldFetchSourceFetchers=true', () async {
      // Arrange - настроим источники для обеих моков
      when(() => setup.mockSourceFetcher2.source)
          .thenReturn(UpdateSource.appStore);
      when(() => setup.mockSourceFetcher2.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenAnswer((_) async => const UpdateConfig());

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher, setup.mockSourceFetcher2],
        searchConfig: const UpdateSearchConfig(
          platform: UpdatePlatform.android,
          sources: [UpdateSource.googlePlay], // Только GooglePlay матчится
        ),
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(
        result,
        hasLength(2),
      ); // default + 1 source (только GooglePlay матчится)
    });

    test('только regular fetchers с shouldFetchFerchers=true', () async {
      // Arrange
      final config1 =
          UpdateConfig(releases: [setup.createReleaseConfig('1.0.0')]);
      final config2 =
          UpdateConfig(releases: [setup.createReleaseConfig('2.0.0')]);
      final fetcher1 = setup.createSimpleFetcher(config1);
      final fetcher2 = setup.createSimpleFetcher(config2);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [fetcher1, fetcher2],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: false,
        shouldFetchFerchers: true,
      );

      // Assert
      expect(result, hasLength(3)); // default + 2 regular
      expect(result[1], config1);
      expect(result[2], config2);
    });

    test('смешанный список с разными флагами - все включены', () async {
      // Arrange
      const sourceConfig = UpdateConfig(customParams: {'type': 'source'});
      const regularConfig = UpdateConfig(customParams: {'type': 'regular'});

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
        shouldFetchFerchers: true,
      );

      // Assert
      expect(result, hasLength(3));
      expect(result[1].customParams?['type'], 'source');
      expect(result[2].customParams?['type'], 'regular');
    });

    test('смешанный список с разными флагами - только regular', () async {
      // Arrange
      const regularConfig = UpdateConfig(customParams: {'type': 'regular'});
      final regularFetcher = setup.createSimpleFetcher(regularConfig);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher, regularFetcher],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: false,
        shouldFetchFerchers: true,
      );

      // Assert
      expect(result, hasLength(2));
      expect(result[1].customParams?['type'], 'regular');
      verifyNever(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          ));
    });
  });
}
