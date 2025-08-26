import 'package:app_update/src/shared/entities/update_platform.dart';
import 'package:app_update/src/shared/entities/update_source.dart';
import 'package:app_update/src/shared/entities/update_source_name.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

import 'helpers/test_utils.dart';

void main() {
  group('UpdateSearcher - findCurrentUpdates', () {
    final searcher = UpdateSearcherTestUtils.searcher;
    final currentDate = UpdateSearcherTestUtils.currentDate;

    test('находит обновления равные локальной версии', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.appStore), // больше локальной → skip
        UpdateSearcherTestUtils.createUpdateData('0.9.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.ruStore), // меньше локальной → break
      ];

      final result = searcher.findCurrentUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [
            UpdateSource.googlePlay,
            UpdateSource.appStore,
            UpdateSource.ruStore
          ],
        ),
        updates: updates,
      );

      expect(result, hasLength(1));
      expect(result[0].version, Version.parse('1.0.0'));
      expect(result[0].sourceName, UpdateSourceName.googlePlay);
    });

    test('возвращает пустой список если нет текущих обновлений', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay), // больше локальной
        UpdateSearcherTestUtils.createUpdateData('0.9.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.appStore), // меньше локальной
      ];

      final result = searcher.findCurrentUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay, UpdateSource.appStore],
        ),
        updates: updates,
      );

      expect(result, isEmpty);
    });

    test('фильтрует по дате, платформе и источникам', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2025), // будущая дата → skip
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.ios, // другая платформа → skip
            source: UpdateSourceName.appStore),
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.ruStore), // не в списке источников → skip
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay), // подходит
      ];

      final result = searcher.findCurrentUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay, UpdateSource.appStore],
        ),
        updates: updates,
      );

      expect(result, hasLength(1));
      expect(result[0].sourceName, UpdateSourceName.googlePlay);
    });

    test('возвращает одно обновление на пару source+platform', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10,
                09), // более ранняя дата, но та же пара source+platform
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final result = searcher.findCurrentUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
        ),
        updates: updates,
      );

      expect(result, hasLength(1));
      expect(result[0].date, DateTime(2024, 10, 10)); // первое найденное
    });

    test('возвращает пустой список для пустого списка обновлений', () {
      final result = searcher.findCurrentUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
        ),
        updates: [],
      );

      expect(result, isEmpty);
    });

    test('сортирует по приоритету источников', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.ruStore),
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final result = searcher.findCurrentUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay, UpdateSource.ruStore],
        ),
        updates: updates,
      );

      expect(result, hasLength(2));
      expect(result.map((e) => e.sourceName).toList(), [
        UpdateSourceName.googlePlay,
        UpdateSourceName.ruStore,
      ]);
    });
  });

  group('UpdateSearcher - findMostRelevantCurrentUpdate', () {
    final searcher = UpdateSearcherTestUtils.searcher;
    final currentDate = UpdateSearcherTestUtils.currentDate;

    test('возвращает самое релевантное текущее обновление', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.appStore),
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final result = searcher.findMostRelevantCurrentUpdate(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [
            UpdateSource.googlePlay,
            UpdateSource.appStore
          ], // googlePlay первый
        ),
        updates: updates,
      );

      expect(result, isNotNull);
      expect(result!.sourceName, UpdateSourceName.googlePlay);
    });

    test('возвращает null если нет текущих обновлений', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay), // больше локальной
      ];

      final result = searcher.findMostRelevantCurrentUpdate(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
        ),
        updates: updates,
      );

      expect(result, isNull);
    });

    test('возвращает null для пустого списка обновлений', () {
      final result = searcher.findMostRelevantCurrentUpdate(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
        ),
        updates: [],
      );

      expect(result, isNull);
    });

    test('учитывает приоритет источников', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.ruStore),
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final result = searcher.findMostRelevantCurrentUpdate(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.ruStore, UpdateSource.googlePlay],
        ),
        updates: updates,
      );

      expect(result, isNotNull);
      expect(result!.sourceName, UpdateSourceName.ruStore);
    });

    test('игнорирует обновления с будущими датами', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2025), // будущая дата
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.ruStore), // ruStore поддерживает Android
      ];

      final result = searcher.findMostRelevantCurrentUpdate(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay, UpdateSource.ruStore],
        ),
        updates: updates,
      );

      expect(result, isNotNull);
      expect(result!.sourceName, UpdateSourceName.ruStore);
    });
  });
}
