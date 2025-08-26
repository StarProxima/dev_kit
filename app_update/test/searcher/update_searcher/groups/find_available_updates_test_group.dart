part of '../update_searcher_test.dart';

void runFindAvailableUpdatesTests() {
  group('UpdateSearcher - findAvailableUpdates', () {
    final searcher = UpdateSearcherTestUtils.searcher;
    final currentDate = UpdateSearcherTestUtils.currentDate;

    test(
        'фильтрует по версии/дате/платформе/источнику; одна запись на пару source+platform',
        () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('2.1.0',
            date: DateTime(2025),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay), // будущая дата → skip
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.ios,
            source: UpdateSourceName.appStore), // другая платформа → skip
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.appStore), // другой источник → skip
        UpdateSearcherTestUtils.createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName
                .googlePlay), // == local → ok, но будет отброшен, т.к. уже есть запись для пары
        UpdateSearcherTestUtils.createUpdateData('0.9.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay), // < local → break
        UpdateSearcherTestUtils.createUpdateData('0.8.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay), // не дойдет (после break)
      ];

      final res = searcher.findAvailableUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
        ),
        updates: updates,
      );

      // Теперь только одна запись на пару source+platform
      expect(res.map((e) => e.version.toString()).toList(), ['2.0.0']);
      expect(res.every((e) => e.platform == UpdatePlatform.android), isTrue);
      expect(res.every((e) => e.sourceName == UpdateSourceName.googlePlay),
          isTrue);
      expect(res.every((e) => !e.date.isAfter(currentDate)), isTrue);
    });

    test('возвращает пусто, если ни один источник не совпал', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.appStore),
      ];

      final res = searcher.findAvailableUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
        ),
        updates: updates,
      );

      expect(res, isEmpty);
    });

    test('выбирает наибольшую версию для каждой пары source+platform', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('1.2.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('1.5.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.appStore),
      ];

      final res = searcher.findAvailableUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay, UpdateSource.appStore],
        ),
        updates: updates,
      );

      // Для пары (googlePlay, android) → 2.0.0
      expect(res.map((e) => e.version.toString()).toList(), ['2.0.0']);
      expect(res.length, 1);
    });

    test(
        'если максимальная версия пары в будущем, берется следующая допустимая',
        () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('3.0.0',
            date: DateTime(2025),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay), // future → skip
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        UpdateSearcherTestUtils.createUpdateData('1.9.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final res = searcher.findAvailableUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
        ),
        updates: updates,
      );

      expect(res.length, 1);
      expect(res.first.version, Version.parse('2.0.0'));
    });

    test(
        'учитывает несколько источников сразу и сортирует по версии по убыванию',
        () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '2.1.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.gitHub,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '1.9.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.ruStore,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '2.1.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
      ];

      final res = searcher.findAvailableUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [
            UpdateSource.googlePlay,
            UpdateSource.gitHub,
            UpdateSource.ruStore
          ],
        ),
        updates: updates,
      );

      expect(res.map((e) => e.version.toString()).toList(),
          ['2.1.0', '2.1.0', '1.9.0']);

      expect(
        res.map((e) => e.sourceName).toList(),
        [
          UpdateSourceName.googlePlay,
          UpdateSourceName.gitHub,
          UpdateSourceName.ruStore,
        ],
      );
    });

    test('одинаковые версии сортируются по приоритету источников из sources',
        () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.gitHub,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.ruStore,
        ),
      ];

      final res = searcher.findAvailableUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [
            UpdateSource.googlePlay,
            UpdateSource.ruStore,
            UpdateSource.gitHub
          ],
        ),
        updates: updates,
      );

      expect(
        res.map((e) => e.sourceName).toList(),
        [
          UpdateSourceName.googlePlay,
          UpdateSourceName.ruStore,
          UpdateSourceName.gitHub
        ],
      );
    });

    test('источники, отсутствующие в списке sources, отфильтровываются', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: const UpdateSourceName.custom('custom')), // нет в списке
        UpdateSearcherTestUtils.createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final res = searcher.findAvailableUpdates(
        searchData: UpdateSearcherTestUtils.createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
        ),
        updates: updates,
      );

      expect(res.length, 1);
      expect(res.first.sourceName, UpdateSourceName.googlePlay);
    });

    group('edge cases', () {
      test('пустой список обновлений возвращает пустой результат', () {
        final result = searcher.findAvailableUpdates(
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

      test('все обновления с будущими датами отфильтровываются', () {
        final updates = [
          UpdateSearcherTestUtils.createUpdateData('2.0.0',
              date: DateTime(2025),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay),
          UpdateSearcherTestUtils.createUpdateData('1.5.0',
              date: DateTime(2025, 02),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.appStore),
        ];

        final result = searcher.findAvailableUpdates(
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

      test('все обновления для других платформ отфильтровываются', () {
        final updates = [
          UpdateSearcherTestUtils.createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.ios,
              source: UpdateSourceName.appStore),
          UpdateSearcherTestUtils.createUpdateData('1.5.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.macos,
              source: UpdateSourceName.appStore),
        ];

        final result = searcher.findAvailableUpdates(
          searchData: UpdateSearcherTestUtils.createSearchData(
            currentDate: currentDate,
            localVersion: Version.parse('1.0.0'),
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.appStore],
          ),
          updates: updates,
        );

        expect(result, isEmpty);
      });
    });
  });
}
