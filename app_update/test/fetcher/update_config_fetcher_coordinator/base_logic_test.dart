import 'dart:ui';

import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';

import '../helpers/coordinator_test_setup.dart';

void main() {
  group('UpdateConfigFetcherCoordinator - базовая логика', () {
    late CoordinatorTestSetup setup;

    setUpAll(CoordinatorTestSetup.setUpAll);

    setUp(() {
      setup = CoordinatorTestSetup();
      setup.setUp();
    });

    test('всегда включает defaultUpdateConfig в начало списка', () async {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData());

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: false,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(1));
      expect(result.first.contentRules, isNotNull);
    });

    test('правильно получает searchData через defaulter', () async {
      // Arrange
      final expectedSearchData = setup.createSearchData(
        platform: UpdatePlatform.ios,
        sources: const [UpdateSource.appStore],
        locale: const UpdateLocale(Locale('ru', 'RU')),
        localVersion: Version.parse('1.5.0'),
      );

      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(expectedSearchData);

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [],
        searchConfig: setup.baseSearchConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: false,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(1)); // Проверяем что вернулся default config
      verify(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: setup.baseSearchConfig,
            packageInfo: setup.packageInfo,
          )).called(1);
    });

    test('правильно передает locale в fetchers', () async {
      // Arrange
      const expectedConfig = UpdateConfig();
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData(
        locale: const UpdateLocale(Locale('ru', 'RU')),
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
      expect(result, hasLength(3)); // default + fetchSourceAppUrl + fetch
      verify(() => setup.mockSourceFetcher.fetch(
            locale: const Locale('ru', 'RU'),
            packageInfo: setup.packageInfo,
          )).called(1);
    });

    test('использует дефолтный locale EN если locale.locale = null', () async {
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
      expect(result, hasLength(3)); // default + fetchSourceAppUrl + fetch
      verify(() => setup.mockSourceFetcher.fetch(
            locale: const Locale('en'),
            packageInfo: setup.packageInfo,
          )).called(1);
    });
  });
}
