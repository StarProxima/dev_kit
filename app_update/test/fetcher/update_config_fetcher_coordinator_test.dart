import 'dart:ui';

import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import 'helpers/mock_source_fetchers.dart';

void main() {
  group('UpdateConfigFetcherCoordinator', () {
    late UpdateConfigFetcherCoordinator coordinator;
    late MockUpdateSearchDataDefaulter mockDefaulter;
    late MockUpdateConfigFetcher mockFetcher;
    late MockUpdateConfigSourceFetcher mockSourceFetcher;
    late MockUpdateConfigSourceFetcher mockSourceFetcher2;
    late MockUpdateConfigFetcher mockFetcher2;
    late PackageInfo packageInfo;
    late UpdateSearchConfig baseSearchConfig;

    /// Создает базовый UpdateSearchData для тестов
    UpdateSearchData createSearchData({
      UpdatePlatform platform = UpdatePlatform.android,
      List<UpdateSource> sources = const [UpdateSource.googlePlay],
      UpdateLocale locale = UpdateLocale.en,
      Version? localVersion,
    }) {
      return UpdateSearchData(
        platform: platform,
        sources: sources,
        localVersion: localVersion ?? Version.parse('1.0.0'),
        displayTarget: UpdateViewTarget.any,
        appStatus: null,
        locale: locale,
        currentDate: DateTime(2024, 10, 15),
        localReleaseDate: null,
        updateReleaseDate: null,
        segmentationPointer: 0,
        rolloutPointer: 0,
        appName: 'Test App',
        appPackageName: 'com.test.app',
        customData: null,
      );
    }

    setUpAll(() {
      // Регистрируем fallback значения
      registerFallbackValue(FakePackageInfo());
      registerFallbackValue(FakeUpdateSearchConfig());
      registerFallbackValue(const Locale('en'));
      registerFallbackValue(UpdateSearchData(
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
        localVersion: Version.parse('1.0.0'),
        displayTarget: UpdateViewTarget.any,
        appStatus: null,
        locale: UpdateLocale.any,
        currentDate: DateTime.now(),
        localReleaseDate: null,
        updateReleaseDate: null,
        segmentationPointer: 0,
        rolloutPointer: 0,
        appName: 'Test',
        appPackageName: 'com.test',
        customData: null,
      ));
    });

    setUp(() {
      mockDefaulter = MockUpdateSearchDataDefaulter();
      coordinator = UpdateConfigFetcherCoordinator(
        updateSearchDataDefaulter: mockDefaulter,
        sourceMatcher: const SourceMatcher(),
      );

      mockFetcher = MockUpdateConfigFetcher();
      mockSourceFetcher = MockUpdateConfigSourceFetcher();
      mockSourceFetcher2 = MockUpdateConfigSourceFetcher();
      mockFetcher2 = MockUpdateConfigFetcher();

      packageInfo = FakePackageInfo();
      baseSearchConfig = const UpdateSearchConfig(
        platform: UpdatePlatform.android,
        sources: [UpdateSource.googlePlay],
      );
    });

    group('базовая логика', () {
      test('всегда включает defaultUpdateConfig в начало списка', () async {
        // Arrange
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(createSearchData());

        // Act
        final result = await coordinator.fetch(
          fetchers: [],
          searchConfig: baseSearchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result.first.contentRules, isNotNull);
      });

      test('правильно получает searchData через defaulter', () async {
        // Arrange
        final expectedSearchData = createSearchData(
          platform: UpdatePlatform.ios,
          sources: const [UpdateSource.appStore],
          locale: UpdateLocale.ru,
          localVersion: Version.parse('1.5.0'),
        );

        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(expectedSearchData);

        // Act
        await coordinator.fetch(
          fetchers: [],
          searchConfig: baseSearchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFerchers: false,
        );

        // Assert
        verify(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: baseSearchConfig,
              packageInfo: packageInfo,
            )).called(1);
      });
    });

    group('обработка UpdateConfigSourceFetcher', () {
      test(
        'выполняет source fetcher при shouldFetchSourceFetchers = true',
        () async {
          // Arrange
          const expectedConfig = UpdateConfig();
          when(() => mockDefaulter.getSearchDataWithDefaults(
                searchConfig: any(named: 'searchConfig'),
                packageInfo: any(named: 'packageInfo'),
              )).thenReturn(createSearchData());

          when(() => mockSourceFetcher.source)
              .thenReturn(UpdateSource.googlePlay);
          when(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              )).thenAnswer((_) async => expectedConfig);

          // Act
          final result = await coordinator.fetch(
            fetchers: [mockSourceFetcher],
            searchConfig: baseSearchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: true,
            shouldFetchFerchers: false,
          );

          // Assert
          expect(result, hasLength(2));
          expect(result.last, expectedConfig);
          verify(() => mockSourceFetcher.fetch(
                locale: const Locale('en'),
                packageInfo: packageInfo,
              )).called(1);
        },
      );

      test(
        'пропускает source fetcher при shouldFetchSourceFetchers = false',
        () async {
          // Arrange
          when(() => mockDefaulter.getSearchDataWithDefaults(
                searchConfig: any(named: 'searchConfig'),
                packageInfo: any(named: 'packageInfo'),
              )).thenReturn(createSearchData());

          when(() => mockSourceFetcher.source)
              .thenReturn(UpdateSource.googlePlay);

          // Act
          final result = await coordinator.fetch(
            fetchers: [mockSourceFetcher],
            searchConfig: baseSearchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: false,
            shouldFetchFerchers: false,
          );

          // Assert
          expect(result, hasLength(1));
          verifyNever(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              ));
        },
      );

      test(
        'пропускает source fetcher если его source не в searchData.sources',
        () async {
          // Arrange
          when(() => mockDefaulter.getSearchDataWithDefaults(
                    searchConfig: any(named: 'searchConfig'),
                    packageInfo: any(named: 'packageInfo'),
                  ))
              .thenReturn(createSearchData(sources: [UpdateSource.googlePlay]));

          when(() => mockSourceFetcher.source)
              .thenReturn(UpdateSource.appStore);

          // Act
          final result = await coordinator.fetch(
            fetchers: [mockSourceFetcher],
            searchConfig: baseSearchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: true,
            shouldFetchFerchers: false,
          );

          // Assert
          expect(result, hasLength(1));
          verifyNever(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              ));
        },
      );

      test(
        'пропускает source fetcher если платформа не поддерживается (с platforms)',
        () async {
          // Arrange
          when(() => mockDefaulter.getSearchDataWithDefaults(
                searchConfig: any(named: 'searchConfig'),
                packageInfo: any(named: 'packageInfo'),
              )).thenReturn(createSearchData(platform: UpdatePlatform.android));

          final sourceWithIosPlatforms = const UpdateSource.custom(
            UpdateSourceName.custom('test'),
            platforms: [UpdatePlatform.ios],
          );
          when(() => mockSourceFetcher.source)
              .thenReturn(sourceWithIosPlatforms);

          // Act
          final result = await coordinator.fetch(
            fetchers: [mockSourceFetcher],
            searchConfig: const UpdateSearchConfig(
              platform: UpdatePlatform.android,
              sources: [
                UpdateSource.custom(
                  UpdateSourceName.custom('test'),
                  platforms: [UpdatePlatform.ios],
                ),
              ],
            ),
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: true,
            shouldFetchFerchers: false,
          );

          // Assert
          expect(result, hasLength(1));
          verifyNever(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              ));
        },
      );

      test(
        'НЕ пропускает source fetcher если platforms = null (поддерживает все платформы)',
        () async {
          // Arrange
          const expectedConfig = UpdateConfig();
          final sourceWithNullPlatforms = const UpdateSource.custom(
            UpdateSourceName.custom('universal'),
            platforms: null, // null = поддерживает все платформы
          );

          when(() => mockDefaulter.getSearchDataWithDefaults(
                searchConfig: any(named: 'searchConfig'),
                packageInfo: any(named: 'packageInfo'),
              )).thenReturn(createSearchData(
            platform: UpdatePlatform.android,
            sources: [sourceWithNullPlatforms], // Включаем source в список
          ));

          when(() => mockSourceFetcher.source)
              .thenReturn(sourceWithNullPlatforms);
          when(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              )).thenAnswer((_) async => expectedConfig);

          // Act
          final result = await coordinator.fetch(
            fetchers: [mockSourceFetcher],
            searchConfig: UpdateSearchConfig(
              platform: UpdatePlatform.android,
              sources: [sourceWithNullPlatforms],
            ),
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: true,
            shouldFetchFerchers: false,
          );

          // Assert
          expect(result, hasLength(2)); // default + source config
          expect(result.last, expectedConfig);
          verify(() => mockSourceFetcher.fetch(
                locale: const Locale('en'),
                packageInfo: packageInfo,
              )).called(1);
        },
      );

      test('обрабатывает UnimplementedError от source fetcher', () async {
        // Arrange
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(createSearchData());

        when(() => mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenThrow(UnimplementedError());

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher],
          searchConfig: baseSearchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(1)); // только default
      });

      test('правильно передает locale в source fetcher', () async {
        // Arrange
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(createSearchData(
          locale: const UpdateLocale(Locale('ru', 'RU')),
        ));

        when(() => mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => const UpdateConfig());

        // Act
        await coordinator.fetch(
          fetchers: [mockSourceFetcher],
          searchConfig: baseSearchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        verify(() => mockSourceFetcher.fetch(
              locale: const Locale('ru', 'RU'),
              packageInfo: packageInfo,
            )).called(1);
      });

      test(
        'использует дефолтный locale EN если locale.locale = null',
        () async {
          // Arrange
          when(() => mockDefaulter.getSearchDataWithDefaults(
                searchConfig: any(named: 'searchConfig'),
                packageInfo: any(named: 'packageInfo'),
              )).thenReturn(createSearchData(locale: UpdateLocale.any));

          when(() => mockSourceFetcher.source)
              .thenReturn(UpdateSource.googlePlay);
          when(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              )).thenAnswer((_) async => const UpdateConfig());

          // Act
          await coordinator.fetch(
            fetchers: [mockSourceFetcher],
            searchConfig: baseSearchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: true,
            shouldFetchFerchers: false,
          );

          // Assert
          verify(() => mockSourceFetcher.fetch(
                locale: const Locale('en'),
                packageInfo: packageInfo,
              )).called(1);
        },
      );
    });

    group('обработка обычных UpdateConfigFetcher', () {
      test(
        'выполняет обычный fetcher при shouldFetchFerchers = true',
        () async {
          // Arrange
          const expectedConfig = UpdateConfig();
          when(() => mockDefaulter.getSearchDataWithDefaults(
                searchConfig: any(named: 'searchConfig'),
                packageInfo: any(named: 'packageInfo'),
              )).thenReturn(createSearchData());

          when(() => mockFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              )).thenAnswer((_) async => expectedConfig);

          // Act
          final result = await coordinator.fetch(
            fetchers: [mockFetcher],
            searchConfig: baseSearchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: false,
            shouldFetchFerchers: true,
          );

          // Assert
          expect(result, hasLength(2));
          expect(result.last, expectedConfig);
          verify(() => mockFetcher.fetch(
                locale: const Locale('en'),
                packageInfo: packageInfo,
              )).called(1);
        },
      );

      test(
        'пропускает обычный fetcher при shouldFetchFerchers = false',
        () async {
          // Arrange
          when(() => mockDefaulter.getSearchDataWithDefaults(
                searchConfig: any(named: 'searchConfig'),
                packageInfo: any(named: 'packageInfo'),
              )).thenReturn(createSearchData());

          // Act
          final result = await coordinator.fetch(
            fetchers: [mockFetcher],
            searchConfig: baseSearchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: false,
            shouldFetchFerchers: false,
          );

          // Assert
          expect(result, hasLength(1));
          verifyNever(() => mockFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              ));
        },
      );
    });

    group('тестирование разных UpdateSearchConfig', () {
      test('обрабатывает iOS с AppStore источником', () async {
        // Arrange
        const expectedConfig = UpdateConfig();
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(createSearchData(
          platform: UpdatePlatform.ios,
          sources: const [UpdateSource.appStore],
        ));

        when(() => mockSourceFetcher.source).thenReturn(UpdateSource.appStore);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => expectedConfig);

        final iosConfig = const UpdateSearchConfig(
          platform: UpdatePlatform.ios,
          sources: [UpdateSource.appStore],
        );

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher],
          searchConfig: iosConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(2));
        verify(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: packageInfo,
            )).called(1);
      });

      test('обрабатывает множественные источники', () async {
        // Arrange
        const googlePlayConfig = UpdateConfig();
        const appStoreConfig = UpdateConfig();
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(createSearchData(
          platform: UpdatePlatform
              .android, // android platform поддерживает только googlePlay
          sources: const [UpdateSource.googlePlay, UpdateSource.appStore],
        ));

        when(() => mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => googlePlayConfig);

        // AppStore не поддерживает Android платформу, поэтому он будет пропущен
        when(() => mockSourceFetcher2.source).thenReturn(UpdateSource.appStore);
        when(() => mockSourceFetcher2.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => appStoreConfig);

        final multiSourceConfig = const UpdateSearchConfig(
          platform: UpdatePlatform.android,
          sources: [UpdateSource.googlePlay, UpdateSource.appStore],
        );

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher, mockSourceFetcher2],
          searchConfig: multiSourceConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(
          result,
          hasLength(
            2,
          ),
        ); // default + только googlePlay (appStore пропущен из-за платформы)
        verify(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).called(1);
        // AppStore не вызывается, так как не поддерживает Android
        verifyNever(() => mockSourceFetcher2.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            ));
      });

      test(
        'обрабатывает кастомный UpdateSearchConfig с дополнительными полями',
        () async {
          // Arrange
          when(() => mockDefaulter.getSearchDataWithDefaults(
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
          final result = await coordinator.fetch(
            fetchers: [],
            searchConfig: complexConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: false,
            shouldFetchFerchers: false,
          );

          // Assert
          expect(result, hasLength(1));
          verify(() => mockDefaulter.getSearchDataWithDefaults(
                searchConfig: complexConfig,
                packageInfo: packageInfo,
              )).called(1);
        },
      );
    });

    group('тестирование разного количества фетчеров', () {
      test('обрабатывает пустой список фетчеров', () async {
        // Arrange
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(createSearchData());

        // Act
        final result = await coordinator.fetch(
          fetchers: [],
          searchConfig: baseSearchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: true,
        );

        // Assert
        expect(result, hasLength(1)); // только default
      });

      test('обрабатывает один source fetcher', () async {
        // Arrange
        const expectedConfig = UpdateConfig();
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(createSearchData());

        when(() => mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => expectedConfig);

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher],
          searchConfig: baseSearchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(2));
        expect(result.last, expectedConfig);
      });

      test(
        'обрабатывает множественные source fetchers с совместимыми платформами',
        () async {
          // Arrange
          const config1 = UpdateConfig();
          const config2 = UpdateConfig();

          // Создаем кастомные источники, которые поддерживают все платформы
          final universalSource1 = const UpdateSource.custom(
            UpdateSourceName.custom('universal1'),
            platforms: null, // поддерживает все платформы
          );
          final universalSource2 = const UpdateSource.custom(
            UpdateSourceName.custom('universal2'),
            platforms: null, // поддерживает все платформы
          );

          when(() => mockDefaulter.getSearchDataWithDefaults(
                searchConfig: any(named: 'searchConfig'),
                packageInfo: any(named: 'packageInfo'),
              )).thenReturn(createSearchData(
            platform: UpdatePlatform.android,
            sources: [universalSource1, universalSource2],
          ));

          when(() => mockSourceFetcher.source).thenReturn(universalSource1);
          when(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              )).thenAnswer((_) async => config1);

          when(() => mockSourceFetcher2.source).thenReturn(universalSource2);
          when(() => mockSourceFetcher2.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              )).thenAnswer((_) async => config2);

          // Act
          final result = await coordinator.fetch(
            fetchers: [mockSourceFetcher, mockSourceFetcher2],
            searchConfig: UpdateSearchConfig(
              platform: UpdatePlatform.android,
              sources: [universalSource1, universalSource2],
            ),
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: true,
            shouldFetchFerchers: false,
          );

          // Assert
          expect(result, hasLength(3)); // default + 2 configs
          expect(result[1], config1);
          expect(result[2], config2);
        },
      );

      test('обрабатывает смешанные типы фетчеров', () async {
        // Arrange
        const sourceConfig = UpdateConfig();
        const regularConfig1 = UpdateConfig();
        const regularConfig2 = UpdateConfig();
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(createSearchData());

        when(() => mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => sourceConfig);

        when(() => mockFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => regularConfig1);

        when(() => mockFetcher2.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => regularConfig2);

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher, mockFetcher, mockFetcher2],
          searchConfig: baseSearchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: true,
        );

        // Assert
        expect(result, hasLength(4)); // default + 1 source + 2 regular
        expect(result[1], sourceConfig);
        expect(result[2], regularConfig1);
        expect(result[3], regularConfig2);
      });
    });

    group('комбинации флагов shouldFetch', () {
      setUp(() {
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(createSearchData());

        when(() => mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => const UpdateConfig());

        when(() => mockFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => const UpdateConfig());
      });

      test(
        'shouldFetchSourceFetchers=true, shouldFetchFerchers=true',
        () async {
          // Act
          final result = await coordinator.fetch(
            fetchers: [mockSourceFetcher, mockFetcher],
            searchConfig: baseSearchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: true,
            shouldFetchFerchers: true,
          );

          // Assert
          expect(result, hasLength(3)); // default + source + regular
          verify(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              )).called(1);
          verify(() => mockFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              )).called(1);
        },
      );

      test(
        'shouldFetchSourceFetchers=false, shouldFetchFerchers=true',
        () async {
          // Act
          final result = await coordinator.fetch(
            fetchers: [mockSourceFetcher, mockFetcher],
            searchConfig: baseSearchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: false,
            shouldFetchFerchers: true,
          );

          // Assert
          expect(result, hasLength(2)); // default + regular
          verifyNever(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              ));
          verify(() => mockFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              )).called(1);
        },
      );

      test(
        'shouldFetchSourceFetchers=true, shouldFetchFerchers=false',
        () async {
          // Act
          final result = await coordinator.fetch(
            fetchers: [mockSourceFetcher, mockFetcher],
            searchConfig: baseSearchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: true,
            shouldFetchFerchers: false,
          );

          // Assert
          expect(result, hasLength(2)); // default + source
          verify(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              )).called(1);
          verifyNever(() => mockFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              ));
        },
      );

      test(
        'shouldFetchSourceFetchers=false, shouldFetchFerchers=false',
        () async {
          // Act
          final result = await coordinator.fetch(
            fetchers: [mockSourceFetcher, mockFetcher],
            searchConfig: baseSearchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: false,
            shouldFetchFerchers: false,
          );

          // Assert
          expect(result, hasLength(1)); // только default
          verifyNever(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              ));
          verifyNever(() => mockFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              ));
        },
      );
    });

    group('обработка ошибок', () {
      setUp(() {
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(createSearchData());
      });

      test('обычный fetcher бросает исключение - прокидывается дальше', () {
        // Arrange
        when(() => mockFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenThrow(Exception('Regular fetcher error'));

        // Act & Assert
        expect(
          () => coordinator.fetch(
            fetchers: [mockFetcher],
            searchConfig: baseSearchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: false,
            shouldFetchFerchers: true,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test(
        'source fetcher бросает не-UnimplementedError - прокидывается дальше',
        () {
          // Arrange
          when(() => mockSourceFetcher.source)
              .thenReturn(UpdateSource.googlePlay);
          when(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              )).thenThrow(Exception('Source fetcher error'));

          // Act & Assert
          expect(
            () => coordinator.fetch(
              fetchers: [mockSourceFetcher],
              searchConfig: baseSearchConfig,
              packageInfo: packageInfo,
              shouldFetchSourceFetchers: true,
              shouldFetchFerchers: false,
            ),
            throwsA(isA<Exception>()),
          );
        },
      );

      test(
        'source fetcher бросает UnimplementedError - игнорируется',
        () async {
          // Arrange
          when(() => mockSourceFetcher.source)
              .thenReturn(UpdateSource.googlePlay);
          when(() => mockSourceFetcher.fetch(
                locale: any(named: 'locale'),
                packageInfo: any(named: 'packageInfo'),
              )).thenThrow(UnimplementedError());

          // Act
          final result = await coordinator.fetch(
            fetchers: [mockSourceFetcher],
            searchConfig: baseSearchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: true,
            shouldFetchFerchers: false,
          );

          // Assert
          expect(result, hasLength(1)); // только default
        },
      );
    });

    group('edge cases', () {
      test('обрабатывает source с пустым списком platforms', () async {
        // Arrange
        const expectedConfig = UpdateConfig();
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(createSearchData());

        final sourceWithEmptyPlatforms = const UpdateSource.custom(
          UpdateSourceName.custom('empty'),
          platforms: [], // Пустой список
        );
        when(() => mockSourceFetcher.source)
            .thenReturn(sourceWithEmptyPlatforms);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => expectedConfig);

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher],
          searchConfig: const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [
              UpdateSource.custom(
                UpdateSourceName.custom('empty'),
                platforms: [],
              ),
            ],
          ),
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(
          result,
          hasLength(1),
        ); // source пропускается из-за пустого списка platforms
        verifyNever(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            ));
      });

      test('обрабатывает source с платформой "any"', () async {
        // Arrange
        const expectedConfig = UpdateConfig();
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(createSearchData(platform: UpdatePlatform.android));

        final sourceWithAnyPlatform = const UpdateSource.custom(
          UpdateSourceName.custom('any_platform'),
          platforms: [UpdatePlatform.any],
        );
        when(() => mockSourceFetcher.source).thenReturn(sourceWithAnyPlatform);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => expectedConfig);

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher],
          searchConfig: const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [
              UpdateSource.custom(
                UpdateSourceName.custom('any_platform'),
                platforms: [UpdatePlatform.any],
              ),
            ],
          ),
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(
          result,
          hasLength(1),
        ); // any platform не матчится с конкретной платформой
        verifyNever(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            ));
      });

      test('обрабатывает поиск с searchData.platform = any', () async {
        // Arrange
        const expectedConfig = UpdateConfig();
        final testSource = const UpdateSource.custom(
          UpdateSourceName.custom('test'),
          platforms: [UpdatePlatform.android],
        );

        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(
          createSearchData(
            platform: UpdatePlatform.any,
            sources: [testSource],
          ),
        );

        when(() => mockSourceFetcher.source).thenReturn(testSource);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => expectedConfig);

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher],
          searchConfig: UpdateSearchConfig(
            platform: UpdatePlatform.any,
            sources: [testSource],
          ),
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(
          result,
          hasLength(2),
        ); // any platform матчится с любой конкретной
        expect(result.last, expectedConfig);
        verify(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).called(1);
      });
    });
  });
}
