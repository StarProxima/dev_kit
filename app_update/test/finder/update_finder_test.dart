import 'package:app_update/src/finder/update_finder.dart';
import 'package:app_update/src/shared/models/release/update_data.dart';
import 'package:app_update/src/shared/models/update_search/update_find_data.dart';
import 'package:app_update/src/shared/update_entities/update_platform.dart';
import 'package:app_update/src/shared/update_entities/update_source.dart';
import 'package:app_update/src/shared/update_entities/update_source_name.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('UpdateFinder', () {
    const finder = UpdateFinder();

    // Хелпер для создания UpdateData
    UpdateData createUpdateData(
      String version, {
      required DateTime date,
      required UpdatePlatform platform,
      required UpdateSourceName source,
    }) {
      return UpdateData(
        version: Version.parse(version),
        date: date,
        sourceName: source,
        platform: platform,
        contentRules: null,
        settingsRules: null,
        appSettingsRules: null,
        customData: null,
      );
    }

    final currentDate = DateTime(2024, 10, 20, 12);

    test('фильтрует по версии/дате/платформе/источнику; одна запись на пару source+platform', () {
      final updates = [
        createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        createUpdateData('2.1.0',
            date: DateTime(2025, 01, 01),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay), // будущая дата → skip
        createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.ios,
            source: UpdateSourceName.appStore), // другая платформа → skip
        createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.appStore), // другой источник → skip
        createUpdateData('1.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName
                .googlePlay), // == local → ok, но будет отброшен, т.к. уже есть запись для пары
        createUpdateData('0.9.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay), // < local → break
        createUpdateData('0.8.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay), // не дойдет (после break)
      ];

      final res = finder.findAvailableUpdates(
        findData: UpdateFindData(
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
      expect(res.every((e) => e.sourceName == UpdateSourceName.googlePlay), isTrue);
      expect(res.every((e) => !e.date.isAfter(currentDate)), isTrue);
    });

    // test('учитывает null дату как допустимую (не фильтрует)', () {
    //   final updates = [
    //     createUpdateData(
    //       '2.0.0',
    //       date: null,
    //       platform: UpdatePlatform.android,
    //       source: UpdateSourceName.googlePlay,
    //     ),
    //     createUpdateData(
    //       '1.5.0',
    //       date: DateTime(2024, 10, 10),
    //       platform: UpdatePlatform.android,
    //       source: UpdateSourceName.googlePlay,
    //     ),
    //   ];

    //   final res = finder.findAvailableUpdates(
    //     findData: UpdateFindData(
    //       currentDate: currentDate,
    //       localVersion: Version.parse('1.0.0'),
    //       platform: UpdatePlatform.android,
    //       sources: const [UpdateSource.googlePlay],
    //     ),
    //     updates: updates,
    //   );

    //   // Одна запись на пару → берется максимальная (2.0.0)
    //   expect(res.length, 1);
    //   expect(res.first.version, Version.parse('2.0.0'));
    // });

    test('возвращает пусто, если ни один источник не совпал', () {
      final updates = [
        createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.appStore),
      ];

      final res = finder.findAvailableUpdates(
        findData: UpdateFindData(
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
        createUpdateData('1.2.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        createUpdateData('1.5.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.appStore),
      ];

      final res = finder.findAvailableUpdates(
        findData: UpdateFindData(
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

    test('если максимальная версия пары в будущем, берется следующая допустимая', () {
      final updates = [
        createUpdateData('3.0.0',
            date: DateTime(2025, 01, 01),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay), // future → skip
        createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        createUpdateData('1.9.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final res = finder.findAvailableUpdates(
        findData: UpdateFindData(
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

    test('учитывает несколько источников сразу и сортирует по версии по убыванию', () {
      final updates = [
        createUpdateData(
          '2.1.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.gitHub,
        ),
        createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
        createUpdateData(
          '1.9.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.ruStore,
        ),
        createUpdateData(
          '2.1.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
      ];

      final res = finder.findAvailableUpdates(
        findData: UpdateFindData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay, UpdateSource.gitHub, UpdateSource.ruStore],
        ),
        updates: updates,
      );

      expect(res.map((e) => e.version.toString()).toList(), ['2.1.0', '2.1.0', '1.9.0']);

      expect(
        res.map((e) => e.sourceName).toList(),
        [
          UpdateSourceName.googlePlay,
          UpdateSourceName.gitHub,
          UpdateSourceName.ruStore,
        ],
      );
    });

    test('одинаковые версии сортируются по приоритету источников из sources', () {
      final updates = [
        createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.gitHub,
        ),
        createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.googlePlay,
        ),
        createUpdateData(
          '2.0.0',
          date: DateTime(2024, 10, 10),
          platform: UpdatePlatform.android,
          source: UpdateSourceName.ruStore,
        ),
      ];

      final res = finder.findAvailableUpdates(
        findData: UpdateFindData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay, UpdateSource.ruStore, UpdateSource.gitHub],
        ),
        updates: updates,
      );

      expect(
        res.map((e) => e.sourceName).toList(),
        [UpdateSourceName.googlePlay, UpdateSourceName.ruStore, UpdateSourceName.gitHub],
      );
    });

    test('источники, отсутствующие в списке sources, отфильтровываются', () {
      final updates = [
        createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: const UpdateSourceName.custom('custom')), // нет в списке
        createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final res = finder.findAvailableUpdates(
        findData: UpdateFindData(
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
  });
}
