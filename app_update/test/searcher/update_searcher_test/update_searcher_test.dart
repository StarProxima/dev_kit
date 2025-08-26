import 'package:app_update/src/searcher/update_search_data_defaulter.dart';
import 'package:app_update/src/searcher/update_searcher.dart';
import 'package:app_update/src/searcher/update_source_support_checker.dart';
import 'package:app_update/src/shared/entities/update_platform.dart';
import 'package:app_update/src/shared/entities/update_source.dart';
import 'package:app_update/src/shared/entities/update_source_name.dart';
import 'package:app_update/src/shared/models/release/update_data.dart';
import 'package:app_update/src/shared/models/update_search/update_search_config.dart';
import 'package:app_update/src/shared/models/update_search/update_search_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('UpdateFinder', () {
    final searchDataDefaulter = UpdateSearchDataDefaulter(
      updateSourceChecker: UpdateSourceSupportCheckerNoOp(),
    );

    UpdateSearchData createSearchData({
      required DateTime currentDate,
      required Version localVersion,
      required UpdatePlatform platform,
      required List<UpdateSource> sources,
    }) {
      final searchConfig = UpdateSearchConfig(
        currentDate: currentDate,
        localVersion: localVersion,
        platform: platform,
        sources: sources,
      );

      return searchDataDefaulter.getSearchDataWithDefaults(
        searchConfig: searchConfig,
        packageInfo: PackageInfo(
          appName: 'test',
          packageName: 'test',
          version: '1.0.0',
          buildNumber: '1',
        ),
      );
    }

    final searcher = UpdateSearcher(
      searchDataDefaulter: searchDataDefaulter,
    );

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

    test(
        'фильтрует по версии/дате/платформе/источнику; одна запись на пару source+platform',
        () {
      final updates = [
        createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
        createUpdateData('2.1.0',
            date: DateTime(2025),
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

      final res = searcher.findAvailableUpdates(
        searchData: createSearchData(
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
        createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.appStore),
      ];

      final res = searcher.findAvailableUpdates(
        searchData: createSearchData(
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

      final res = searcher.findAvailableUpdates(
        searchData: createSearchData(
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
        createUpdateData('3.0.0',
            date: DateTime(2025),
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

      final res = searcher.findAvailableUpdates(
        searchData: createSearchData(
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

      final res = searcher.findAvailableUpdates(
        searchData: createSearchData(
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

      final res = searcher.findAvailableUpdates(
        searchData: createSearchData(
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
        createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: const UpdateSourceName.custom('custom')), // нет в списке
        createUpdateData('2.0.0',
            date: DateTime(2024, 10, 10),
            platform: UpdatePlatform.android,
            source: UpdateSourceName.googlePlay),
      ];

      final res = searcher.findAvailableUpdates(
        searchData: createSearchData(
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

    group('findMostRelevantUpdate', () {
      test('возвращает самое релевантное обновление (первое из доступных)', () {
        final updates = [
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay),
          createUpdateData('1.5.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.appStore),
        ];

        final result = searcher.findMostRelevantUpdate(
          searchData: createSearchData(
            currentDate: currentDate,
            localVersion: Version.parse('1.0.0'),
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay, UpdateSource.appStore],
          ),
          updates: updates,
        );

        expect(result, isNotNull);
        expect(result!.version, Version.parse('2.0.0'));
        expect(result.sourceName, UpdateSourceName.googlePlay);
      });

      test('возвращает null если нет доступных обновлений', () {
        final updates = [
          createUpdateData('0.9.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay), // меньше локальной версии
        ];

        final result = searcher.findMostRelevantUpdate(
          searchData: createSearchData(
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
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.ruStore),
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay),
        ];

        final result = searcher.findMostRelevantUpdate(
          searchData: createSearchData(
            currentDate: currentDate,
            localVersion: Version.parse('1.0.0'),
            platform: UpdatePlatform.android,
            sources: const [
              UpdateSource.ruStore,
              UpdateSource.googlePlay
            ], // ruStore первый
          ),
          updates: updates,
        );

        expect(result, isNotNull);
        expect(result!.sourceName.name, UpdateSourceName.ruStore.name);
      });
    });

    group('findCurrentUpdates', () {
      test('находит обновления равные локальной версии', () {
        final updates = [
          createUpdateData('1.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay),
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.appStore), // больше локальной → skip
          createUpdateData('0.9.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.ruStore), // меньше локальной → break
        ];

        final result = searcher.findCurrentUpdates(
          searchData: createSearchData(
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
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay), // больше локальной
          createUpdateData('0.9.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.appStore), // меньше локальной
        ];

        final result = searcher.findCurrentUpdates(
          searchData: createSearchData(
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
          createUpdateData('1.0.0',
              date: DateTime(2025), // будущая дата → skip
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay),
          createUpdateData('1.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.ios, // другая платформа → skip
              source: UpdateSourceName.appStore),
          createUpdateData('1.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source:
                  UpdateSourceName.ruStore), // не в списке источников → skip
          createUpdateData('1.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay), // подходит
        ];

        final result = searcher.findCurrentUpdates(
          searchData: createSearchData(
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
          createUpdateData('1.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay),
          createUpdateData('1.0.0',
              date: DateTime(2024, 10,
                  09), // более ранняя дата, но та же пара source+platform
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay),
        ];

        final result = searcher.findCurrentUpdates(
          searchData: createSearchData(
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
    });

    group('findMostRelevantCurrentUpdate', () {
      test('возвращает самое релевантное текущее обновление', () {
        final updates = [
          createUpdateData('1.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.appStore),
          createUpdateData('1.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay),
        ];

        final result = searcher.findMostRelevantCurrentUpdate(
          searchData: createSearchData(
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
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay), // больше локальной
        ];

        final result = searcher.findMostRelevantCurrentUpdate(
          searchData: createSearchData(
            currentDate: currentDate,
            localVersion: Version.parse('1.0.0'),
            platform: UpdatePlatform.android,
            sources: const [UpdateSource.googlePlay],
          ),
          updates: updates,
        );

        expect(result, isNull);
      });
    });

    group('sortUpdates', () {
      test('сортирует по версии по убыванию', () {
        final updates = [
          createUpdateData('1.0.0',
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
              source: UpdateSourceName.googlePlay),
        ];

        final findData = createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
        );

        final result = searcher.sortUpdates(updates, findData);

        expect(result.map((e) => e.version.toString()).toList(),
            ['2.0.0', '1.5.0', '1.0.0']);
      });

      test('при одинаковой версии сортирует по приоритету источника', () {
        final updates = [
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.ruStore),
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay),
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.appStore),
        ];

        final findData = createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [
            UpdateSource.appStore,
            UpdateSource.googlePlay,
            UpdateSource.ruStore
          ],
        );

        final result = searcher.sortUpdates(updates, findData);

        expect(result.map((e) => e.sourceName).toList(), [
          UpdateSourceName.appStore,
          UpdateSourceName.googlePlay,
          UpdateSourceName.ruStore
        ]);
      });

      test('источники не в списке sources помещаются в конец', () {
        final updates = [
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: const UpdateSourceName.custom('unknown')), // не в sources
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay), // в sources
        ];

        final findData = createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay],
        );

        final result = searcher.sortUpdates(updates, findData);

        expect(result.map((e) => e.sourceName).toList(), [
          UpdateSourceName.googlePlay,
          const UpdateSourceName.custom('unknown')
        ]);
      });

      test('комбинированная сортировка: версия + приоритет источника', () {
        final updates = [
          createUpdateData('1.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay),
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.appStore),
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay),
        ];

        final findData = createSearchData(
          currentDate: currentDate,
          localVersion: Version.parse('1.0.0'),
          platform: UpdatePlatform.android,
          sources: const [UpdateSource.googlePlay, UpdateSource.appStore],
        );

        final result = searcher.sortUpdates(updates, findData);

        // Сначала версия 2.0.0 (googlePlay имеет приоритет над appStore)
        // Затем версия 1.0.0
        expect(result.map((e) => '${e.version}-${e.sourceName.name}').toList(),
            ['2.0.0-googleplay', '2.0.0-appstore', '1.0.0-googleplay']);
      });
    });

    group('дополнительные edge cases для findAvailableUpdates', () {
      test('пустой список обновлений возвращает пустой результат', () {
        final result = searcher.findAvailableUpdates(
          searchData: createSearchData(
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
          createUpdateData('2.0.0',
              date: DateTime(2025),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.googlePlay),
          createUpdateData('1.5.0',
              date: DateTime(2025, 02),
              platform: UpdatePlatform.android,
              source: UpdateSourceName.appStore),
        ];

        final result = searcher.findAvailableUpdates(
          searchData: createSearchData(
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
          createUpdateData('2.0.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.ios,
              source: UpdateSourceName.appStore),
          createUpdateData('1.5.0',
              date: DateTime(2024, 10, 10),
              platform: UpdatePlatform.macos,
              source: UpdateSourceName.appStore),
        ];

        final result = searcher.findAvailableUpdates(
          searchData: createSearchData(
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
