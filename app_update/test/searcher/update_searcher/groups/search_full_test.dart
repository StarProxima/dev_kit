import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../helpers/test_utils.dart';

void main() {
  group('UpdateSearcher - searchFull', () {
    final searcher = UpdateSearcherTestUtils.searcher;
    final currentDate = UpdateSearcherTestUtils.currentDate;

    test('возвращает результат с доступным и текущим обновлением', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 9, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final searchConfig = UpdateSearchConfig(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
      );

      final packageInfo = UpdateSearcherTestUtils.createPackageInfo();

      final result = searcher.searchFull(
        updates: updates,
        searchConfig: searchConfig,
        packageInfo: packageInfo,
      );

      // Проверяем что найдено доступное обновление
      expect(result.updateData, isNotNull);
      expect(result.updateData!.version, Version.parse('2.0.0'));
      expect(result.updateData!.sourceName, UpdateSourceName.googlePlay);

      // Проверяем что найдено текущее обновление
      expect(result.localUpdateData, isNotNull);
      expect(result.localUpdateData!.version, Version.parse('1.0.0'));
      expect(result.localUpdateData!.sourceName, UpdateSourceName.googlePlay);

      // Проверяем что searchData содержит правильные даты
      expect(result.searchData.localReleaseDate, DateTime(2024, 9, 10));
      expect(result.searchData.updateReleaseDate, DateTime(2024, 10, 10));

      // Проверяем базовые поля searchData
      expect(result.searchData.localVersion, Version.parse('1.0.0'));
      expect(result.searchData.platform, UpdatePlatform.android);
      expect(result.searchData.currentDate, currentDate);
    });

    test('возвращает результат только с доступным обновлением', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final searchConfig = UpdateSearchConfig(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
      );

      final packageInfo = UpdateSearcherTestUtils.createPackageInfo();

      final result = searcher.searchFull(
        updates: updates,
        searchConfig: searchConfig,
        packageInfo: packageInfo,
      );

      expect(result.updateData, isNotNull);
      expect(result.updateData!.version, Version.parse('2.0.0'));
      expect(result.localUpdateData, isNull);
      expect(result.searchData.localReleaseDate, isNull);
      expect(result.searchData.updateReleaseDate, DateTime(2024, 10, 10));
    });

    test('возвращает результат только с текущим обновлением', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 9, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('0.9.0',
            date: DateTime(2024, 8, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final searchConfig = UpdateSearchConfig(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
      );

      final packageInfo = UpdateSearcherTestUtils.createPackageInfo();

      final result = searcher.searchFull(
        updates: updates,
        searchConfig: searchConfig,
        packageInfo: packageInfo,
      );

      expect(result.updateData, isNull);
      expect(result.localUpdateData, isNotNull);
      expect(result.localUpdateData!.version, Version.parse('1.0.0'));
      expect(result.searchData.localReleaseDate, DateTime(2024, 9, 10));
      expect(result.searchData.updateReleaseDate, isNull);
    });

    test('возвращает результат без обновлений', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('0.9.0',
            date: DateTime(2024, 8, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final searchConfig = UpdateSearchConfig(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
      );

      final packageInfo = UpdateSearcherTestUtils.createPackageInfo();

      final result = searcher.searchFull(
        updates: updates,
        searchConfig: searchConfig,
        packageInfo: packageInfo,
      );

      expect(result.updateData, isNull);
      expect(result.localUpdateData, isNull);
      expect(result.searchData.localReleaseDate, isNull);
      expect(result.searchData.updateReleaseDate, isNull);
    });

    test('использует дефолтные значения из UpdateSearchDataDefaulter', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      // Конфиг с минимальными параметрами
      const searchConfig = UpdateSearchConfig();

      final packageInfo = PackageInfo(
        appName: 'TestApp',
        packageName: 'com.test.app',
        version: '1.5.0',
        buildNumber: '42',
      );

      final result = searcher.searchFull(
        updates: updates,
        searchConfig: searchConfig,
        packageInfo: packageInfo,
      );

      // Проверяем что используются значения из packageInfo
      expect(result.searchData.appName, 'TestApp');
      expect(result.searchData.appPackageName, 'com.test.app');
      expect(result.searchData.localVersion, Version.parse('1.5.0+42'));

      // Проверяем что используется текущее время (приблизительно)
      final now = DateTime.now();
      expect(result.searchData.currentDate.difference(now).inMinutes.abs(),
          lessThan(5));
    });

    test('переопределяет дефолтные значения из searchConfig', () {
      final customDate = DateTime(2024, 5, 15, 10, 30);
      final customVersion = Version.parse('0.8.0');

      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final searchConfig = UpdateSearchConfig(
        currentDate: customDate,
        localVersion: customVersion,
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
        appName: 'CustomApp',
        appPackageName: 'com.custom.app',
      );

      final packageInfo = UpdateSearcherTestUtils.createPackageInfo(
        appName: 'DefaultApp',
        packageName: 'com.default.app',
      );

      final result = searcher.searchFull(
        updates: updates,
        searchConfig: searchConfig,
        packageInfo: packageInfo,
      );

      // Проверяем что используются значения из searchConfig
      expect(result.searchData.currentDate, customDate);
      expect(result.searchData.localVersion, customVersion);
      expect(result.searchData.appName, 'CustomApp');
      expect(result.searchData.appPackageName, 'com.custom.app');
      expect(result.searchData.platform, UpdatePlatform.android);
    });

    test('обрабатывает пустой список обновлений', () {
      final searchConfig = UpdateSearchConfig(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
      );

      final packageInfo = UpdateSearcherTestUtils.createPackageInfo();

      final result = searcher.searchFull(
        updates: [],
        searchConfig: searchConfig,
        packageInfo: packageInfo,
      );

      expect(result.updateData, isNull);
      expect(result.localUpdateData, isNull);
      expect(result.searchData.localReleaseDate, isNull);
      expect(result.searchData.updateReleaseDate, isNull);
      expect(result.searchData.localVersion, Version.parse('1.0.0'));
    });

    test('правильно обрабатывает приоритеты источников', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.ruStore),
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 9, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.ruStore),
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 9, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final searchConfig = UpdateSearchConfig(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [
          UpdateSource.ruStore,
          UpdateSource.googlePlay
        ], // ruStore имеет приоритет
      );

      final packageInfo = UpdateSearcherTestUtils.createPackageInfo();

      final result = searcher.searchFull(
        updates: updates,
        searchConfig: searchConfig,
        packageInfo: packageInfo,
      );

      // При одинаковой версии выбирается источник с высшим приоритетом
      expect(result.updateData!.sourceName, UpdateSourceName.ruStore);
      expect(result.localUpdateData!.sourceName, UpdateSourceName.ruStore);
    });

    test('фильтрует по платформе', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.ios, // другая платформа
            source: UpdateSourceName.appStore),
        UpdateSearcherTestUtils.createUpdateData('1.5.0',
            date: DateTime(2024, 9, 10),
            platform: UpdatePlatform.android, // целевая платформа
            source: UpdateSourceName.googlePlay),
      ];

      final searchConfig = UpdateSearchConfig(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay, UpdateSource.appStore],
      );

      final packageInfo = UpdateSearcherTestUtils.createPackageInfo();

      final result = searcher.searchFull(
        updates: updates,
        searchConfig: searchConfig,
        packageInfo: packageInfo,
      );

      // Должно найти только обновление для Android
      expect(result.updateData, isNotNull);
      expect(result.updateData!.version, Version.parse('1.5.0'));
      expect(result.updateData!.platform, UpdatePlatform.android);
    });

    test('фильтрует по дате', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2025), // будущая дата
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('1.8.0',
            date: DateTime(2024, 10, 10), // подходящая дата
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final searchConfig = UpdateSearchConfig(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
      );

      final packageInfo = UpdateSearcherTestUtils.createPackageInfo();

      final result = searcher.searchFull(
        updates: updates,
        searchConfig: searchConfig,
        packageInfo: packageInfo,
      );

      // Должно игнорировать обновление с будущей датой
      expect(result.updateData, isNotNull);
      expect(result.updateData!.version, Version.parse('1.8.0'));
      expect(result.updateData!.date, DateTime(2024, 10, 10));
    });

    test('обновляет searchData с найденными датами релизов', () {
      final localUpdateDate = DateTime(2024, 8, 15);
      final availableUpdateDate = DateTime(2024, 10, 20);

      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.5.0',
            date: availableUpdateDate,
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: localUpdateDate,
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final searchConfig = UpdateSearchConfig(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
        localReleaseDate: DateTime(2024, 7), // исходное значение
        updateReleaseDate: DateTime(2024, 6), // исходное значение
      );

      final packageInfo = UpdateSearcherTestUtils.createPackageInfo();

      final result = searcher.searchFull(
        updates: updates,
        searchConfig: searchConfig,
        packageInfo: packageInfo,
      );

      // Проверяем что даты обновились
      expect(result.searchData.localReleaseDate, localUpdateDate);
      expect(result.searchData.updateReleaseDate, availableUpdateDate);
    });
  });
}
