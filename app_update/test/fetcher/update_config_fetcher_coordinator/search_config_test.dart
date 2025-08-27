import 'dart:ui';

import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pub_semver/pub_semver.dart';

import '../helpers/coordinator_test_setup.dart';

void main() {
  group('UpdateConfigFetcherCoordinator - разные UpdateSearchConfig', () {
    late CoordinatorTestSetup setup;

    setUpAll(() {
      CoordinatorTestSetup.setUpAll();
    });

    setUp(() {
      setup = CoordinatorTestSetup();
      setup.setUp();
    });

    test('обрабатывает iOS с AppStore источником', () async {
      // Arrange
      const expectedConfig = UpdateConfig();
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData(
        platform: UpdatePlatform.ios,
        sources: const [UpdateSource.appStore],
      ));

      when(() => setup.mockSourceFetcher.source)
          .thenReturn(UpdateSource.appStore);
      when(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenAnswer((_) async => expectedConfig);

      final iosConfig = const UpdateSearchConfig(
        platform: UpdatePlatform.ios,
        sources: [UpdateSource.appStore],
      );

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher],
        searchConfig: iosConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(2));
      verify(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: setup.packageInfo,
          )).called(1);
    });

    test('обрабатывает Android с множественными источниками', () async {
      // Arrange
      const googlePlayConfig =
          UpdateConfig(customData: {'source': 'googlePlay'});

      // Создаем кастомный Android-совместимый источник
      final customAndroidSource = const UpdateSource.custom(
        UpdateSourceName.custom('custom_android'),
        platforms: [UpdatePlatform.android],
      );

      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(setup.createSearchData(
        platform: UpdatePlatform.android,
        sources: [UpdateSource.googlePlay, customAndroidSource],
      ));

      when(() => setup.mockSourceFetcher.source)
          .thenReturn(UpdateSource.googlePlay);
      when(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: any(named: 'packageInfo'),
          )).thenAnswer((_) async => googlePlayConfig);

      final androidConfig = UpdateSearchConfig(
        platform: UpdatePlatform.android,
        sources: [UpdateSource.googlePlay, customAndroidSource],
      );

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [setup.mockSourceFetcher],
        searchConfig: androidConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: true,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(
          result,
          hasLength(
              2)); // default + googlePlay (customAndroidSource не матчится без второго fetcher)
      verify(() => setup.mockSourceFetcher.fetch(
            locale: any(named: 'locale'),
            packageInfo: setup.packageInfo,
          )).called(1);
    });

    test('обрабатывает кастомные параметры UpdateSearchConfig', () async {
      // Arrange
      when(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: any(named: 'searchConfig'),
            packageInfo: any(named: 'packageInfo'),
          )).thenReturn(UpdateSearchData(
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
        localVersion: Version.parse('2.5.0'),
        displayTarget: UpdateViewTarget.card,
        appStatus: const AppStatus.custom('updateable'),
        locale: const UpdateLocale(Locale('fr', 'FR')),
        currentDate: DateTime(2024, 12, 25),
        localReleaseDate: DateTime(2024, 10, 1),
        updateReleaseDate: DateTime(2024, 11, 15),
        segmentationPointer: 0.75,
        rolloutPointer: 0.9,
        appName: 'Custom App',
        appPackageName: 'com.custom.package',
        customData: const {'theme': 'dark', 'region': 'eu'},
      ));

      final complexConfig = UpdateSearchConfig(
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
        localVersion: Version.parse('2.5.0'),
        displayTarget: UpdateViewTarget.card,
        locale: const UpdateLocale(Locale('fr', 'FR')),
        currentDate: DateTime(2024, 12, 25),
        appStatus: const AppStatus.custom('updateable'),
        segmentationPointer: 0.75,
        rolloutPointer: 0.9,
        customData: const {'theme': 'dark', 'region': 'eu'},
      );

      // Act
      final result = await setup.coordinator.fetch(
        fetchers: [],
        searchConfig: complexConfig,
        packageInfo: setup.packageInfo,
        shouldFetchSourceFetchers: false,
        shouldFetchFerchers: false,
      );

      // Assert
      expect(result, hasLength(1));
      verify(() => setup.mockDefaulter.getSearchDataWithDefaults(
            searchConfig: complexConfig,
            packageInfo: setup.packageInfo,
          )).called(1);
    });

    test('обрабатывает разные локали', () async {
      // Arrange
      final testLocales = [
        const UpdateLocale(Locale('en')),
        const UpdateLocale(Locale('ru', 'RU')),
        const UpdateLocale(Locale('fr', 'FR')),
        const UpdateLocale(Locale('de')),
      ];

      for (final locale in testLocales) {
        when(() => setup.mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(setup.createSearchData(locale: locale));

        when(() => setup.mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);
        when(() => setup.mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => const UpdateConfig());

        final config = UpdateSearchConfig(
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          locale: locale,
        );

        // Act
        await setup.coordinator.fetch(
          fetchers: [setup.mockSourceFetcher],
          searchConfig: config,
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        final expectedLocale = locale.locale ?? const Locale('en');
        verify(() => setup.mockSourceFetcher.fetch(
              locale: expectedLocale,
              packageInfo: setup.packageInfo,
            )).called(1);

        // Reset для следующей итерации
        reset(setup.mockSourceFetcher);
        reset(setup.mockDefaulter);
      }
    });

    test('обрабатывает разные платформы', () async {
      // Arrange
      final platformTests = [
        {
          'platform': UpdatePlatform.android,
          'source': UpdateSource.googlePlay,
          'shouldMatch': true,
        },
        {
          'platform': UpdatePlatform.ios,
          'source': UpdateSource.appStore,
          'shouldMatch': true,
        },
        {
          'platform': UpdatePlatform.macos,
          'source': UpdateSource.appStore,
          'shouldMatch': true,
        },
        {
          'platform': UpdatePlatform.android,
          'source': UpdateSource.appStore, // AppStore не поддерживает Android
          'shouldMatch': false,
        },
        {
          'platform': UpdatePlatform.ios,
          'source': UpdateSource.googlePlay, // GooglePlay не поддерживает iOS
          'shouldMatch': false,
        },
      ];

      for (final test in platformTests) {
        final platform = test['platform'] as UpdatePlatform;
        final source = test['source'] as UpdateSource;
        final shouldMatch = test['shouldMatch'] as bool;

        when(() => setup.mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(setup.createSearchData(
          platform: platform,
          sources: [source],
        ));

        when(() => setup.mockSourceFetcher.source).thenReturn(source);
        when(() => setup.mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => const UpdateConfig());

        final config = UpdateSearchConfig(
          platform: platform,
          sources: [source],
        );

        // Act
        final result = await setup.coordinator.fetch(
          fetchers: [setup.mockSourceFetcher],
          searchConfig: config,
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        if (shouldMatch) {
          expect(
            result,
            hasLength(2),
            reason: '$platform should work with $source',
          );
          verify(() => setup.mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: setup.packageInfo,
              )).called(1);
        } else {
          expect(
            result,
            hasLength(1),
            reason: '$platform should NOT work with $source',
          );
          verifyNever(() => setup.mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: setup.packageInfo,
              ));
        }

        // Reset для следующей итерации
        reset(setup.mockSourceFetcher);
        reset(setup.mockDefaulter);
      }
    });

    test('обрабатывает разные версии приложения', () async {
      // Arrange
      final versions = [
        Version.parse('1.0.0'),
        Version.parse('2.5.0+123'),
        Version.parse('0.1.0-beta'),
        Version.parse('10.15.7'),
      ];

      for (final version in versions) {
        when(() => setup.mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(setup.createSearchData(localVersion: version));

        final config = UpdateSearchConfig(
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          localVersion: version,
        );

        // Act
        final result = await setup.coordinator.fetch(
          fetchers: [],
          searchConfig: config,
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(1));
        verify(() => setup.mockDefaulter.getSearchDataWithDefaults(
              searchConfig: config,
              packageInfo: setup.packageInfo,
            )).called(1);

        // Reset для следующей итерации
        reset(setup.mockDefaulter);
      }
    });

    test('обрабатывает кастомные данные в searchConfig', () async {
      // Arrange
      final customDataVariants = [
        <String, dynamic>{},
        {'theme': 'dark'},
        {'region': 'eu', 'language': 'en'},
        {
          'features': ['feature1', 'feature2'],
          'version_code': 123
        },
      ];

      for (final customData in customDataVariants) {
        when(() => setup.mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(UpdateSearchData(
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          localVersion: Version.parse('1.0.0'),
          displayTarget: UpdateViewTarget.card,
          appStatus: null,
          locale: const UpdateLocale(Locale('en')),
          currentDate: DateTime(2024, 10, 15),
          localReleaseDate: null,
          updateReleaseDate: null,
          segmentationPointer: 0,
          rolloutPointer: 0,
          appName: 'Test App',
          appPackageName: 'com.test.app',
          customData: customData.isEmpty ? null : customData,
        ));

        final config = UpdateSearchConfig(
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          customData: customData.isEmpty ? null : customData,
        );

        // Act
        final result = await setup.coordinator.fetch(
          fetchers: [],
          searchConfig: config,
          packageInfo: setup.packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(1));

        // Reset для следующей итерации
        reset(setup.mockDefaulter);
      }
    });
  });
}
