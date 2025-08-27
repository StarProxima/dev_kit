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
    // late MockGooglePlayFetcher mockGooglePlayFetcher;
    late PackageInfo packageInfo;
    late UpdateSearchConfig searchConfig;

    setUpAll(() {
      // Регистрируем fallback значения
      registerFallbackValue(FakePackageInfo());
      registerFallbackValue(FakeUpdateSearchConfig());
      registerFallbackValue(const Locale('en'));
      registerFallbackValue(UpdateSearchData(
        currentDate: DateTime.now(),
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
        appName: 'Test',
        appPackageName: 'com.test',
        appStatus: null,
        locale: UpdateLocale.any,
        displayTarget: UpdateViewTarget.any,
        rolloutPointer: 0,
        segmentationPointer: 0,
        localReleaseDate: null,
        updateReleaseDate: null,
        customData: null,
      ));
    });

    setUp(() {
      mockDefaulter = MockUpdateSearchDataDefaulter();
      coordinator = UpdateConfigFetcherCoordinator(
        updateSearchDataDefaulter: mockDefaulter,
      );

      mockFetcher = MockUpdateConfigFetcher();
      mockSourceFetcher = MockUpdateConfigSourceFetcher();
      // mockGooglePlayFetcher = MockGooglePlayFetcher();

      packageInfo = FakePackageInfo();
      searchConfig = const UpdateSearchConfig(
        platform: UpdatePlatform.android,
        sources: [UpdateSource.googlePlay],
      );
    });

    group('основная логика fetch', () {
      test('всегда включает defaultUpdateConfig в начало списка', () async {
        // Arrange
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'Test',
          appPackageName: 'com.test',
          appStatus: null,
          locale: UpdateLocale.any,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0,
          segmentationPointer: 0,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        ));

        // Act
        final result = await coordinator.fetch(
          fetchers: [],
          searchConfig: searchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(1));
        expect(result.first.contentRules,
            isNotNull); // defaultUpdateConfig имеет content
      });

      test('правильно получает searchData через defaulter', () async {
        // Arrange
        final expectedSearchData = UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.5.0'),
          platform: UpdatePlatform.ios,
          sources: const [UpdateSource.appStore],
          appName: 'Custom App',
          appPackageName: 'com.custom.app',
          appStatus: null,
          locale: UpdateLocale.ru,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0.8,
          segmentationPointer: 0.3,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        );

        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(expectedSearchData);

        // Act
        await coordinator.fetch(
          fetchers: [],
          searchConfig: searchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFerchers: false,
        );

        // Assert
        verify(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: searchConfig,
              packageInfo: packageInfo,
            )).called(1);
      });
    });

    group('обработка UpdateConfigSourceFetcher', () {
      setUp(() {
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'Test',
          appPackageName: 'com.test',
          appStatus: null,
          locale: UpdateLocale.en,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0,
          segmentationPointer: 0,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        ));
      });

      test('выполняет source fetcher если shouldFetchSourceFetchers = true',
          () async {
        // Arrange
        const expectedConfig = UpdateConfig();

        when(() => mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => expectedConfig);

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher],
          searchConfig: searchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(2)); // default + source fetcher
        expect(result.last, expectedConfig);
        verify(() => mockSourceFetcher.fetch(
              locale: const Locale('en'),
              packageInfo: packageInfo,
            )).called(1);
      });

      test('пропускает source fetcher если shouldFetchSourceFetchers = false',
          () async {
        // Arrange
        when(() => mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher],
          searchConfig: searchConfig,
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
      });

      test('пропускает source fetcher если его source не в searchData.sources',
          () async {
        // Arrange
        when(() => mockSourceFetcher.source)
            .thenReturn(UpdateSource.appStore); // НЕ googlePlay

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher],
          searchConfig: searchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(1)); // только default
        verifyNever(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            ));
      });

      test('пропускает source fetcher если платформа не поддерживается',
          () async {
        // Arrange
        final sourceWithIosPlatforms = MockUpdateConfigSourceFetcher();
        when(() => sourceWithIosPlatforms.source).thenReturn(
            const UpdateSource.custom(UpdateSourceName.custom('test'),
                platforms: [UpdatePlatform.ios]) // НЕ android
            );

        // Act
        final result = await coordinator.fetch(
          fetchers: [sourceWithIosPlatforms],
          searchConfig: const UpdateSearchConfig(
            platform: UpdatePlatform.android, // поиск android
            sources: [
              UpdateSource.custom(UpdateSourceName.custom('test'),
                  platforms: [UpdatePlatform.ios])
            ], // но source только iOS
          ),
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(1)); // только default
        verifyNever(() => sourceWithIosPlatforms.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            ));
      });

      test('обрабатывает UnimplementedError от source fetcher', () async {
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
          searchConfig: searchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(1)); // только default, source fetcher пропущен
      });

      test('правильно передает locale в source fetcher', () async {
        // Arrange
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'Test',
          appPackageName: 'com.test',
          appStatus: null,
          locale: const UpdateLocale(Locale('ru', 'RU')),
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0,
          segmentationPointer: 0,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
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
          searchConfig: searchConfig,
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

      test('использует дефолтный locale EN если locale.locale = null',
          () async {
        // Arrange
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'Test',
          appPackageName: 'com.test',
          appStatus: null,
          locale: UpdateLocale.any, // locale.locale = null
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0,
          segmentationPointer: 0,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
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
          searchConfig: searchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        verify(() => mockSourceFetcher.fetch(
              locale: const Locale('en'),
              packageInfo: packageInfo,
            )).called(1);
      });
    });

    group('обработка обычных UpdateConfigFetcherBase', () {
      setUp(() {
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'Test',
          appPackageName: 'com.test',
          appStatus: null,
          locale: UpdateLocale.en,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0,
          segmentationPointer: 0,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        ));
      });

      test('выполняет обычный fetcher если shouldFetchFerchers = true',
          () async {
        // Arrange
        const expectedConfig = UpdateConfig();

        when(() => mockFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => expectedConfig);

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockFetcher],
          searchConfig: searchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFerchers: true,
        );

        // Assert
        expect(result, hasLength(2)); // default + fetcher
        expect(result.last, expectedConfig);
        verify(() => mockFetcher.fetch(
              locale: const Locale('en'),
              packageInfo: packageInfo,
            )).called(1);
      });

      test('пропускает обычный fetcher если shouldFetchFerchers = false',
          () async {
        // Act
        final result = await coordinator.fetch(
          fetchers: [mockFetcher],
          searchConfig: searchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: false,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(1)); // только default
        verifyNever(() => mockFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            ));
      });
    });

    group('смешанные сценарии', () {
      setUp(() {
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay, UpdateSource.appStore],
          appName: 'Test',
          appPackageName: 'com.test',
          appStatus: null,
          locale: UpdateLocale.en,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0,
          segmentationPointer: 0,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        ));
      });

      test('обрабатывает и source fetchers и обычные fetchers одновременно',
          () async {
        // Arrange
        const sourceConfig = UpdateConfig();
        const regularConfig = UpdateConfig();

        when(() => mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => sourceConfig);

        when(() => mockFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => regularConfig);

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher, mockFetcher],
          searchConfig: const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [UpdateSource.googlePlay],
          ),
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: true,
        );

        // Assert
        expect(result, hasLength(3)); // default + source + regular
        expect(result[1], sourceConfig);
        expect(result[2], regularConfig);
      });

      test(
          'правильно обрабатывает несколько source fetchers с разными условиями',
          () async {
        // Arrange
        final mockAppStoreFetcher = MockUpdateConfigSourceFetcher();
        const googlePlayConfig = UpdateConfig();

        when(() => mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);
        when(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => googlePlayConfig);

        when(() => mockAppStoreFetcher.source)
            .thenReturn(UpdateSource.appStore);
        when(() => mockAppStoreFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenAnswer((_) async => const UpdateConfig());

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher, mockAppStoreFetcher],
          searchConfig: const UpdateSearchConfig(
            platform: UpdatePlatform.android,
            sources: [UpdateSource.googlePlay], // только googlePlay в sources
          ),
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: false,
        );

        // Assert
        expect(result, hasLength(2)); // default + только googlePlay
        expect(result.last, googlePlayConfig);

        verify(() => mockSourceFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).called(1);

        verifyNever(() => mockAppStoreFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            ));
      });

      test('обрабатывает пустой список fetchers', () async {
        // Act
        final result = await coordinator.fetch(
          fetchers: [],
          searchConfig: searchConfig,
          packageInfo: packageInfo,
          shouldFetchSourceFetchers: true,
          shouldFetchFerchers: true,
        );

        // Assert
        expect(result, hasLength(1)); // только default
      });

      test('обрабатывает все флаги отключенными', () async {
        // Arrange - добавляем мок для source, чтобы избежать null subtype error
        when(() => mockSourceFetcher.source)
            .thenReturn(UpdateSource.googlePlay);

        // Act
        final result = await coordinator.fetch(
          fetchers: [mockSourceFetcher, mockFetcher],
          searchConfig: searchConfig,
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
      });
    });

    group('обработка ошибок', () {
      setUp(() {
        when(() => mockDefaulter.getSearchDataWithDefaults(
              searchConfig: any(named: 'searchConfig'),
              packageInfo: any(named: 'packageInfo'),
            )).thenReturn(UpdateSearchData(
          currentDate: DateTime(2024, 10, 15),
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
          appName: 'Test',
          appPackageName: 'com.test',
          appStatus: null,
          locale: UpdateLocale.en,
          displayTarget: UpdateViewTarget.any,
          rolloutPointer: 0,
          segmentationPointer: 0,
          localReleaseDate: null,
          updateReleaseDate: null,
          customData: null,
        ));
      });

      test('обычный fetcher бросает исключение - прокидывается дальше',
          () async {
        // Arrange
        when(() => mockFetcher.fetch(
              locale: any(named: 'locale'),
              packageInfo: any(named: 'packageInfo'),
            )).thenThrow(Exception('Regular fetcher error'));

        // Act & Assert
        expect(
          () => coordinator.fetch(
            fetchers: [mockFetcher],
            searchConfig: searchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: false,
            shouldFetchFerchers: true,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test(
          'source fetcher бросает не-UnimplementedError - прокидывается дальше',
          () async {
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
            searchConfig: searchConfig,
            packageInfo: packageInfo,
            shouldFetchSourceFetchers: true,
            shouldFetchFerchers: false,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
