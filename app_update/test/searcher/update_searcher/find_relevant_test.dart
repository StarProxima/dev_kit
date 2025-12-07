import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

import 'helpers/test_utils.dart';

void main() {
  group('UpdateSearcher - findMostRelevantUpdate', () {
    final searcher = UpdateSearcherTestUtils.searcher;
    final currentDate = UpdateSearcherTestUtils.currentDate;

    test('возвращает самое релевантное обновление (первое из доступных)', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '1.5.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.appStore,
        ),
      ];

      final result = searcher.findMostRelevantUpdate(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay, UpdateSource.appStore],
        ),
        updates: updates,
      );

      expect(result, isNotNull);
      expect(result?.version, Version.parse('2.0.0'));
      expect(result?.sourceName, UpdateSourceName.googlePlay);
    });

    test('возвращает null если нет доступных обновлений', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '0.9.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ), // меньше локальной версии
      ];

      final result = searcher.findMostRelevantUpdate(
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

    test('учитывает приоритет источников при одинаковой версии', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.ruStore,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
      ];

      final result = searcher.findMostRelevantUpdate(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [
            UpdateSource.ruStore,
            UpdateSource.googlePlay,
          ], // ruStore первый
        ),
        updates: updates,
      );

      expect(result, isNotNull);
      expect(result?.sourceName.name, UpdateSourceName.ruStore.name);
    });

    test('возвращает null для пустого списка обновлений', () {
      final result = searcher.findMostRelevantUpdate(
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

    test('игнорирует обновления с будущими датами', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2025), // будущая дата
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '1.5.0',
          date: DateTime(2024, 10, 10), // подходящая дата
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
      ];

      final result = searcher.findMostRelevantUpdate(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
        ),
        updates: updates,
      );

      expect(result, isNotNull);
      expect(result?.version, Version.parse('1.5.0'));
    });

    test('возвращает обновление с максимальной версией', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '1.5.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '2.1.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.ruStore,
        ), // ruStore поддерживает Android
        UpdateSearcherTestUtils.createUpdateData(
          '1.8.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
      ];

      final result = searcher.findMostRelevantUpdate(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay, UpdateSource.ruStore],
        ),
        updates: updates,
      );

      expect(result, isNotNull);
      expect(result?.version, Version.parse('2.1.0'));
      expect(result?.sourceName, UpdateSourceName.ruStore);
    });

    test('работает с единственным подходящим обновлением', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
      ];

      final result = searcher.findMostRelevantUpdate(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
        ),
        updates: updates,
      );

      expect(result, isNotNull);
      expect(result?.version, Version.parse('2.0.0'));
      expect(result?.sourceName, UpdateSourceName.googlePlay);
    });
  });
}
