import 'dart:ui';

import 'package:app_update/app_update.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import 'mock_source_fetchers.dart';

/// Базовый setup для всех тестов координатора
class CoordinatorTestSetup {
  late UpdateConfigFetcherCoordinator coordinator;
  late MockUpdateSearchDataDefaulter mockDefaulter;
  late MockUpdateConfigSourceFetcher mockSourceFetcher;
  late MockUpdateConfigSourceFetcher mockSourceFetcher2;
  late PackageInfo packageInfo;
  late UpdateSearchConfig baseSearchConfig;

  /// Создает базовый UpdateSearchData для тестов (без any параметров)
  UpdateSearchData createSearchData({
    UpdatePlatform platform = UpdatePlatform.android,
    List<UpdateSource> sources = const [UpdateSource.googlePlay],
    UpdateLocale? locale,
    Version? localVersion,
  }) {
    return UpdateSearchData(
      platform: platform,
      sources: sources,
      appVersion: localVersion ?? Version.parse('1.0.0'),
      displayTarget: UpdateViewTarget.card,
      appStatus: null,
      locale: locale ?? const UpdateLocale(Locale('en')),
      currentDate: DateTime(2024, 10, 15),
      localReleaseDate: null,
      updateReleaseDate: null,
      appUpdateDate: null,
      appInstallDate: null,
      userSegmentationPointer: 0,
      rolloutPointer: 0,
      appName: 'Test App',
      appPackageName: 'com.test.app',
      customParams: null,
    );
  }

  /// Создает простой UpdateConfigFetcher с данными
  UpdateConfigFetcher createSimpleFetcher(UpdateConfig config) {
    return UpdateConfigFetcher.config(config);
  }

  /// Создает ReleaseConfig с правильными типами
  ReleaseConfig createReleaseConfig(String version, {String? date}) {
    return ReleaseConfig(
      version: Version.parse(version),
      date: DateTime.parse(date ?? '2024-01-01T00:00:00Z'),
    );
  }

  /// Создает простой UpdateConfig с релизом
  UpdateConfig createSimpleConfig(
    String version, {
    Map<String, dynamic>? customParams,
  }) {
    return UpdateConfig(
      releases: [createReleaseConfig(version)],
      customParams: customParams,
    );
  }

  /// Создает UpdateConfigFetcher из временного файла
  UpdateConfigFetcher createFileFetcher(Map<String, dynamic> yamlData) {
    // В реальности нужно создать временный файл, но для тестов используем custom
    return UpdateConfigFetcher.custom(() => const UpdateConfig());
  }

  void setUp() {
    mockDefaulter = MockUpdateSearchDataDefaulter();
    coordinator = UpdateConfigFetcherCoordinator(
      updateSearchDataDefaulter: mockDefaulter,
      sourceMatcher: const SourceMatcher(),
    );

    mockSourceFetcher = MockUpdateConfigSourceFetcher();
    mockSourceFetcher2 = MockUpdateConfigSourceFetcher();

    // Stub по умолчанию для fetchSourceAppUrl
    when(() => mockSourceFetcher.fetchSourceAppUrl(
          locale: any(named: 'locale'),
          packageInfo: any(named: 'packageInfo'),
        )).thenAnswer((_) async => const UpdateConfig());
    when(() => mockSourceFetcher2.fetchSourceAppUrl(
          locale: any(named: 'locale'),
          packageInfo: any(named: 'packageInfo'),
        )).thenAnswer((_) async => const UpdateConfig());

    packageInfo = FakePackageInfo();
    baseSearchConfig = const UpdateSearchConfig(
      platform: UpdatePlatform.android,
      sources: [UpdateSource.googlePlay],
    );
  }

  static void setUpAll() {
    // Регистрируем fallback значения
    registerFallbackValue(FakePackageInfo());
    registerFallbackValue(FakeUpdateSearchConfig());
    registerFallbackValue(const Locale('en'));
    registerFallbackValue(UpdateSearchData(
      platform: UpdatePlatform.android,
      sources: const [UpdateSource.googlePlay],
      appVersion: Version.parse('1.0.0'),
      displayTarget: UpdateViewTarget.card,
      appStatus: null,
      locale: const UpdateLocale(Locale('en')),
      currentDate: DateTime.now(),
      localReleaseDate: null,
      updateReleaseDate: null,
      appUpdateDate: null,
      appInstallDate: null,
      userSegmentationPointer: 0,
      rolloutPointer: 0,
      appName: 'Test',
      appPackageName: 'com.test',
      customParams: null,
    ));
  }
}
