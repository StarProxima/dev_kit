import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

import 'helpers/test_utils.dart';

void main() {
  group('UpdateSearcher - sortUpdates', () {
    final searcher = UpdateSearcherTestUtils.searcher;
    final currentDate = UpdateSearcherTestUtils.currentDate;

    test('сортирует по версии по убыванию', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '1.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
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
          source: UpdateSourceName.googlePlay,
        ),
      ];

      final findData = UpdateSearcherTestUtils.createSearchData(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
      );

      final result = searcher.sortUpdates(updates, findData);

      expect(
        result.map((e) => e.version.toString()).toList(),
        ['2.0.0', '1.5.0', '1.0.0'],
      );
    });

    test('при одинаковой версии сортирует по приоритету источника', () {
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
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.appStore,
        ),
      ];

      final findData = UpdateSearcherTestUtils.createSearchData(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [
          UpdateSource.appStore,
          UpdateSource.googlePlay,
          UpdateSource.ruStore,
        ],
      );

      final result = searcher.sortUpdates(updates, findData);

      expect(result.map((e) => e.sourceName).toList(), [
        UpdateSourceName.appStore,
        UpdateSourceName.googlePlay,
        UpdateSourceName.ruStore,
      ]);
    });

    test('источники не в списке sources помещаются в конец', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: const UpdateSourceName.custom('unknown'),
        ), // не в sources
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ), // в sources
      ];

      final findData = UpdateSearcherTestUtils.createSearchData(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
      );

      final result = searcher.sortUpdates(updates, findData);

      expect(result.map((e) => e.sourceName).toList(), [
        UpdateSourceName.googlePlay,
        const UpdateSourceName.custom('unknown'),
      ]);
    });

    test('комбинированная сортировка: версия + приоритет источника', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '1.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.appStore,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
      ];

      final findData = UpdateSearcherTestUtils.createSearchData(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay, UpdateSource.appStore],
      );

      final result = searcher.sortUpdates(updates, findData);

      // Сначала версия 2.0.0 (googlePlay имеет приоритет над appStore)
      // Затем версия 1.0.0
      expect(
        result.map((e) => '${e.version}-${e.sourceName.name}').toList(),
        ['2.0.0-googleplay', '2.0.0-appstore', '1.0.0-googleplay'],
      );
    });

    test('пустой список остается пустым', () {
      final findData = UpdateSearcherTestUtils.createSearchData(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
      );

      final result = searcher.sortUpdates([], findData);

      expect(result, isEmpty);
    });

    test('единственный элемент остается без изменений', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
      ];

      final findData = UpdateSearcherTestUtils.createSearchData(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
      );

      final result = searcher.sortUpdates(updates, findData);

      expect(result, hasLength(1));
      expect(result.firstOrNull?.version, Version.parse('2.0.0'));
      expect(result.firstOrNull?.sourceName, UpdateSourceName.googlePlay);
    });

    test('сложная сортировка с несколькими версиями и источниками', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '1.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.ruStore,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.ruStore,
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '1.5.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
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

      final findData = UpdateSearcherTestUtils.createSearchData(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [
          UpdateSource.googlePlay,
          UpdateSource.appStore,
          UpdateSource.ruStore,
        ],
      );

      final result = searcher.sortUpdates(updates, findData);

      // Ожидаем: 2.0.0 (googlePlay, ruStore), 1.5.0 (googlePlay, appStore), 1.0.0 (ruStore)
      final expected = [
        '2.0.0-googleplay',
        '2.0.0-rustore',
        '1.5.0-googleplay',
        '1.5.0-appstore',
        '1.0.0-rustore',
      ];

      expect(
        result.map((e) => '${e.version}-${e.sourceName.name}').toList(),
        expected,
      );
    });

    test('обрабатывает множественные неизвестные источники', () {
      final updates = [
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: const UpdateSourceName.custom('unknown1'),
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: const UpdateSourceName.custom('unknown2'),
        ),
        UpdateSearcherTestUtils.createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
      ];

      final findData = UpdateSearcherTestUtils.createSearchData(
        currentDate: currentDate,
        localVersion: Version.parse('1.0.0'),
        platform: UpdatePlatform.android,
        sources: const [UpdateSource.googlePlay],
      );

      final result = searcher.sortUpdates(updates, findData);

      // GooglePlay должен быть первым, затем неизвестные источники
      expect(result.firstOrNull?.sourceName, UpdateSourceName.googlePlay);
      expect(result[1].sourceName, const UpdateSourceName.custom('unknown1'));
      expect(result[2].sourceName, const UpdateSourceName.custom('unknown2'));
    });
  });
}
