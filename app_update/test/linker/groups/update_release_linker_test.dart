import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('UpdateReleaseLinker', () {
    const linker = UpdateReleaseLinker();

    // Тестовые источники
    final sources = [
      UpdateSource.googlePlay,
      UpdateSource.appStore,
      UpdateSource.gitHub,
    ];

    // Хелперы для создания тестовых данных
    ReleaseConfig createRelease({
      required Version version,
      DateTime? date,
      List<ReleaseSourceConfig>? sources,
      List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
      List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
      List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
      Map<String, dynamic>? customData,
    }) {
      return ReleaseConfig(
        version: version,
        date: date ?? DateTime.now(),
        sources: sources,
        contentRules: contentRules,
        settingsRules: settingsRules,
        appSettingsRules: appSettingsRules,
        customData: customData,
      );
    }

    ReleaseSourceConfig createSource({
      required UpdateSourceName sourceName,
      List<ReleasePlatformConfig>? platforms,
      ReleaseOverrideConfig? releaseOverride,
      List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
      List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
      List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
      Map<String, dynamic>? customData,
    }) {
      return ReleaseSourceConfig(
        sourceName: sourceName,
        platforms: platforms,
        releaseOverride: releaseOverride,
        contentRules: contentRules,
        settingsRules: settingsRules,
        appSettingsRules: appSettingsRules,
        customData: customData,
      );
    }

    ReleasePlatformConfig createPlatform({
      required UpdatePlatform platformName,
      ReleaseOverrideConfig? releaseOverride,
      List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
      List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
      List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
      Map<String, dynamic>? customData,
    }) {
      return ReleasePlatformConfig(
        platformName: platformName,
        releaseOverride: releaseOverride,
        contentRules: contentRules,
        settingsRules: settingsRules,
        appSettingsRules: appSettingsRules,
        customData: customData,
      );
    }

    UpdateRuleConfig<UpdateContentConfig> createContentRule({
      String? title,
      String? description,
    }) {
      return UpdateRuleConfig<UpdateContentConfig>(
        data: UpdateContentConfig(
          title: title,
          description: description,
        ),
      );
    }

    UpdateRuleConfig<UpdateSettingsConfig> createSettingsRule({
      bool? shouldShow,
      bool? canSkip,
    }) {
      return UpdateRuleConfig<UpdateSettingsConfig>(
        data: UpdateSettingsConfig(
          shouldShow: shouldShow,
          canSkip: canSkip,
        ),
      );
    }

    UpdateRuleConfig<UpdateAppSettingsConfig> createAppSettingsRule({
      AppStatus? appStatus,
    }) {
      return UpdateRuleConfig<UpdateAppSettingsConfig>(
        data: UpdateAppSettingsConfig(
          appStatus: appStatus,
        ),
      );
    }

    group('link', () {
      group('базовая логика', () {
        test('возвращает пустой список если sources == null', () {
          final release = createRelease(
            version: Version.parse('1.0.0'),
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, isEmpty);
        });

        test('возвращает пустой список если sources пустой', () {
          final release = createRelease(
            version: Version.parse('1.0.0'),
            sources: [],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, isEmpty);
        });

        test('возвращает пустой список для неизвестных источников', () {
          final release = createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                  sourceName: const UpdateSourceName.custom('unknown')),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, isEmpty);
        });

        test('возвращает пустой список если источник не имеет платформ', () {
          // Создаем источник который не существует в глобальном списке источников
          final customSources = [
            const UpdateSource.custom(
              UpdateSourceName.custom('noplatforms'),
              platforms: [], // Пустой список платформ
            ),
          ];

          final release = createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                  sourceName: const UpdateSourceName.custom('noplatforms')),
            ],
          );

          final result = linker.link(release: release, sources: customSources);

          expect(result, isEmpty);
        });
      });

      group('создание платформ', () {
        test('создает обновления с заданными платформами', () {
          final release = createRelease(
            version: Version.parse('1.0.0'),
            date: DateTime(2024, 10, 20),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(platformName: UpdatePlatform.android),
                ],
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, hasLength(1));
          expect(result[0].version, Version.parse('1.0.0'));
          expect(result[0].date, DateTime(2024, 10, 20));
          expect(result[0].sourceName, UpdateSourceName.googlePlay);
          expect(result[0].platform, UpdatePlatform.android);
        });

        test(
            'создает платформы из UpdateSource.platforms когда platforms == null',
            () {
          final release = createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          // Google Play поддерживает только Android
          expect(result, hasLength(1));
          expect(result[0].platform, UpdatePlatform.android);
        });

        test('создает обновления для нескольких платформ', () {
          final release = createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.appStore,
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          // App Store поддерживает iOS и macOS
          expect(result, hasLength(2));
          expect(result.map((e) => e.platform),
              containsAll([UpdatePlatform.ios, UpdatePlatform.macos]));
        });

        test(
            'комбинирует заданные и автоматические платформы для разных источников',
            () {
          final release = createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(platformName: UpdatePlatform.android),
                ],
              ),
              createSource(
                sourceName: UpdateSourceName.appStore,
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, hasLength(3)); // 1 Android + 2 (iOS + macOS)
          final platforms = result.map((e) => e.platform).toList();
          expect(
              platforms,
              containsAll([
                UpdatePlatform.android,
                UpdatePlatform.ios,
                UpdatePlatform.macos
              ]));
        });

        test('обрабатывает кастомные источники с кастомными платформами', () {
          final customSources = [
            const UpdateSource.custom(
              UpdateSourceName.custom('custom'),
              platforms: [UpdatePlatform.linux, UpdatePlatform.windows],
            ),
          ];

          final release = createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                sourceName: const UpdateSourceName.custom('custom'),
              ),
            ],
          );

          final result = linker.link(release: release, sources: customSources);

          expect(result, hasLength(2));
          expect(result.map((e) => e.platform),
              containsAll([UpdatePlatform.linux, UpdatePlatform.windows]));
        });
      });

      group('переопределения ReleaseOverrideConfig', () {
        test('применяет переопределения версии из источника', () {
          final overrideVersion = Version.parse('2.0.0');
          final release = createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(platformName: UpdatePlatform.android)
                ],
                releaseOverride:
                    ReleaseOverrideConfig(version: overrideVersion),
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, hasLength(1));
          expect(result[0].version, overrideVersion);
        });

        test('применяет переопределения даты из источника', () {
          final overrideDate = DateTime(2024, 12, 25);
          final release = createRelease(
            version: Version.parse('1.0.0'),
            date: DateTime(2024, 10, 20),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(platformName: UpdatePlatform.android)
                ],
                releaseOverride: ReleaseOverrideConfig(date: overrideDate),
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, hasLength(1));
          expect(result[0].date, overrideDate);
        });

        test('переопределения платформы имеют приоритет над источником', () {
          final platformVersion = Version.parse('3.0.0');
          final sourceVersion = Version.parse('2.0.0');

          final release = createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(
                    platformName: UpdatePlatform.android,
                    releaseOverride:
                        ReleaseOverrideConfig(version: platformVersion),
                  ),
                ],
                releaseOverride: ReleaseOverrideConfig(version: sourceVersion),
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, hasLength(1));
          expect(result[0].version, platformVersion);
        });

        test(
            'переопределения даты платформы имеют приоритет над источником и релизом',
            () {
          final platformDate = DateTime(2024, 12, 31);
          final sourceDate = DateTime(2024, 12, 25);
          final releaseDate = DateTime(2024, 10, 20);

          final release = createRelease(
            version: Version.parse('1.0.0'),
            date: releaseDate,
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(
                    platformName: UpdatePlatform.android,
                    releaseOverride: ReleaseOverrideConfig(date: platformDate),
                  ),
                ],
                releaseOverride: ReleaseOverrideConfig(date: sourceDate),
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, hasLength(1));
          expect(result[0].date, platformDate);
        });

        test(
            'применяет переопределения кастомных данных с правильным приоритетом',
            () {
          final release = createRelease(
            version: Version.parse('1.0.0'),
            customData: {'release': 'data', 'shared': 'release'},
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                customData: {'source': 'data', 'shared': 'source'},
                releaseOverride: const ReleaseOverrideConfig(
                  customData: {
                    'sourceOverride': 'data',
                    'shared': 'sourceOverride'
                  },
                ),
                platforms: [
                  createPlatform(
                    platformName: UpdatePlatform.android,
                    customData: {'platform': 'data', 'shared': 'platform'},
                    releaseOverride: const ReleaseOverrideConfig(
                      customData: {
                        'platformOverride': 'data',
                        'shared': 'platformOverride'
                      },
                    ),
                  ),
                ],
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, hasLength(1));
          final customData = result[0].customData!;
          expect(customData['release'], 'data');
          expect(customData['source'], 'data');
          expect(customData['sourceOverride'], 'data');
          expect(customData['platform'], 'data');
          expect(customData['platformOverride'], 'data');
          expect(customData['shared'],
              'platformOverride'); // платформа override имеет высший приоритет
        });

        // test('использует Version.none если никакая версия не задана', () {
        //   final release = createRelease(
        //     version: null,
        //     sources: [
        //       createSource(
        //         sourceName: UpdateSourceName.googlePlay,
        //         platforms: [createPlatform(platformName: UpdatePlatform.android)],
        //       ),
        //     ],
        //   );

        //   final result = linker.link(release: release, sources: sources);

        //   expect(result, hasLength(1));
        //   expect(result[0].version, Version.none);
        // });
      });

      group('объединение правил', () {
        test(
            'объединяет правила в правильном приоритете (релиз -> источник -> платформа)',
            () {
          final releaseRule = createContentRule(title: 'Release Title');
          final sourceRule =
              createContentRule(description: 'Source Description');
          final platformRule = createContentRule(title: 'Platform Title');

          final release = createRelease(
            version: Version.parse('1.0.0'),
            contentRules: [releaseRule],
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                contentRules: [sourceRule],
                platforms: [
                  createPlatform(
                    platformName: UpdatePlatform.android,
                    contentRules: [platformRule],
                  ),
                ],
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, hasLength(1));
          expect(result[0].contentRules, hasLength(3));

          final firstRule = result[0].contentRules![0];
          expect(firstRule.data.title, releaseRule.data.title);
          expect(firstRule.versionIs,
              contains(UpdateVersionConstraint(release.version)));
          expect(
            firstRule.sourceIs?.firstOrNull?.sourceName,
            equals(UpdateSourceName.googlePlay),
          );
          expect(
            firstRule.sourceIs?.firstOrNull?.platforms,
            equals([UpdatePlatform.android]),
          );

          final secondRule = result[0].contentRules![1];
          expect(secondRule.data.description, sourceRule.data.description);
          expect(secondRule.versionIs,
              contains(UpdateVersionConstraint(release.version)));
          expect(
            secondRule.sourceIs?.firstOrNull?.sourceName,
            equals(UpdateSourceName.googlePlay),
          );
          expect(
            secondRule.sourceIs?.firstOrNull?.platforms,
            equals([UpdatePlatform.android]),
          );

          final thirdRule = result[0].contentRules![2];
          expect(thirdRule.data.title, platformRule.data.title);
          expect(thirdRule.versionIs,
              contains(UpdateVersionConstraint(release.version)));
          expect(
            thirdRule.sourceIs?.firstOrNull?.sourceName,
            equals(UpdateSourceName.googlePlay),
          );
          expect(
            thirdRule.sourceIs?.firstOrNull?.platforms,
            equals([UpdatePlatform.android]),
          );
        });

        test('объединяет все типы правил', () {
          final contentRule = createContentRule(title: 'Title');
          final settingsRule = createSettingsRule(shouldShow: true);
          final appSettingsRule =
              createAppSettingsRule(appStatus: AppStatus.active);

          final release = createRelease(
            version: Version.parse('1.0.0'),
            contentRules: [contentRule],
            settingsRules: [settingsRule],
            appSettingsRules: [appSettingsRule],
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(platformName: UpdatePlatform.android)
                ],
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, hasLength(1));
          final firstContentRule = result[0].contentRules![0];
          expect(firstContentRule.data.title, equals('Title'));
          expect(firstContentRule.versionIs,
              contains(UpdateVersionConstraint(release.version)));
          expect(
            firstContentRule.sourceIs?.firstOrNull?.sourceName,
            equals(UpdateSourceName.googlePlay),
          );
          expect(
            firstContentRule.sourceIs?.firstOrNull?.platforms,
            equals([UpdatePlatform.android]),
          );

          final firstSettingsRule = result[0].settingsRules![0];
          expect(firstSettingsRule.data.shouldShow, equals(true));
          expect(firstSettingsRule.versionIs,
              contains(UpdateVersionConstraint(release.version)));
          expect(
            firstSettingsRule.sourceIs?.firstOrNull?.sourceName,
            equals(UpdateSourceName.googlePlay),
          );
          expect(
            firstSettingsRule.sourceIs?.firstOrNull?.platforms,
            equals([UpdatePlatform.android]),
          );

          final firstAppSettingsRule = result[0].appSettingsRules![0];
          expect(firstAppSettingsRule.data.appStatus, equals(AppStatus.active));
          expect(firstAppSettingsRule.versionIs,
              contains(UpdateVersionConstraint(release.version)));
          expect(
            firstAppSettingsRule.sourceIs?.firstOrNull?.sourceName,
            equals(UpdateSourceName.googlePlay),
          );
          expect(
            firstAppSettingsRule.sourceIs?.firstOrNull?.platforms,
            equals([UpdatePlatform.android]),
          );
        });

        test('обрабатывает множественные правила одного типа', () {
          final releaseRule1 = createContentRule(title: 'Release Title 1');
          final releaseRule2 = createContentRule(title: 'Release Title 2');
          final sourceRule =
              createContentRule(description: 'Source Description');
          final platformRule1 = createContentRule(title: 'Platform Title 1');
          final platformRule2 = createContentRule(title: 'Platform Title 2');

          final release = createRelease(
            version: Version.parse('1.0.0'),
            contentRules: [releaseRule1, releaseRule2],
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                contentRules: [sourceRule],
                platforms: [
                  createPlatform(
                    platformName: UpdatePlatform.android,
                    contentRules: [platformRule1, platformRule2],
                  ),
                ],
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, hasLength(1));
          expect(result[0].contentRules, hasLength(5));
          // Порядок: релиз (2), источник (1), платформа (2)
          expect(result[0].contentRules![0].data.title,
              equals(releaseRule1.data.title));
          expect(result[0].contentRules![1].data.title,
              equals(releaseRule2.data.title));
          expect(result[0].contentRules![2].data.description,
              equals(sourceRule.data.description));
          expect(result[0].contentRules![3].data.title,
              equals(platformRule1.data.title));
          expect(result[0].contentRules![4].data.title,
              equals(platformRule2.data.title));
        });

        test('возвращает null для правил если все списки пустые', () {
          final release = createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(
                    platformName: UpdatePlatform.android,
                  ),
                ],
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, hasLength(1));
          expect(result[0].contentRules, isNull);
          expect(result[0].settingsRules, isNull);
          expect(result[0].appSettingsRules, isNull);
        });

        test('обрабатывает смешанные null и пустые списки правил', () {
          final contentRule = createContentRule(title: 'Title');

          final release = createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                contentRules: [], // пустой список
                platforms: [
                  createPlatform(
                    platformName: UpdatePlatform.android,
                    contentRules: [contentRule], // есть правила
                  ),
                ],
              ),
            ],
          );

          final result = linker.link(release: release, sources: sources);

          expect(result, hasLength(1));
          expect(result[0].contentRules, hasLength(1));
          expect(result[0].contentRules![0].data.title,
              equals(contentRule.data.title));
        });
      });
    });

    group('linkAll', () {
      test('обрабатывает пустой список релизов', () {
        final result = linker.linkAll(releases: [], sources: sources);

        expect(result, isEmpty);
      });

      test('объединяет обновления от нескольких релизов', () {
        final releases = [
          createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(platformName: UpdatePlatform.android)
                ],
              ),
            ],
          ),
          createRelease(
            version: Version.parse('1.1.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.appStore,
              ),
            ],
          ),
        ];

        final result = linker.linkAll(releases: releases, sources: sources);

        expect(result, hasLength(3)); // 1 Android + 2 (iOS + macOS)
        expect(
            result.map((e) => e.version),
            containsAll([
              Version.parse('1.0.0'),
              Version.parse('1.1.0'),
              Version.parse('1.1.0'),
            ]));
      });

      test('пропускает релизы без источников', () {
        final releases = [
          createRelease(
            version: Version.parse('1.0.0'),
          ),
          createRelease(
            version: Version.parse('1.1.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(platformName: UpdatePlatform.android)
                ],
              ),
            ],
          ),
        ];

        final result = linker.linkAll(releases: releases, sources: sources);

        expect(result, hasLength(1));
        expect(result[0].version, Version.parse('1.1.0'));
      });

      test('обрабатывает релизы с неизвестными источниками', () {
        final releases = [
          createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                  sourceName: const UpdateSourceName.custom('unknown')),
            ],
          ),
          createRelease(
            version: Version.parse('1.1.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(platformName: UpdatePlatform.android)
                ],
              ),
            ],
          ),
        ];

        final result = linker.linkAll(releases: releases, sources: sources);

        expect(result, hasLength(1));
        expect(result[0].version, Version.parse('1.1.0'));
      });

      test('сохраняет порядок релизов в результате', () {
        final releases = [
          createRelease(
            version: Version.parse('3.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(platformName: UpdatePlatform.android)
                ],
              ),
            ],
          ),
          createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(platformName: UpdatePlatform.android)
                ],
              ),
            ],
          ),
          createRelease(
            version: Version.parse('2.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(platformName: UpdatePlatform.android)
                ],
              ),
            ],
          ),
        ];

        final result = linker.linkAll(releases: releases, sources: sources);

        expect(result, hasLength(3));
        expect(result[0].version, Version.parse('3.0.0'));
        expect(result[1].version, Version.parse('1.0.0'));
        expect(result[2].version, Version.parse('2.0.0'));
      });

      test(
          'обрабатывает сложный случай с множественными источниками и платформами',
          () {
        final releases = [
          createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createPlatform(platformName: UpdatePlatform.android)
                ],
              ),
              createSource(
                sourceName: UpdateSourceName.appStore,
              ),
            ],
          ),
          createRelease(
            version: Version.parse('2.0.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.gitHub,
              ),
            ],
          ),
        ];

        final result = linker.linkAll(releases: releases, sources: sources);

        // Релиз 1.0.0: 1 Android + 2 (iOS + macOS) = 3
        // Релиз 2.0.0: 4 (Android, Windows, Linux, macOS) = 4
        // Итого: 7
        expect(result, hasLength(7));

        final version100Count =
            result.where((e) => e.version == Version.parse('1.0.0')).length;
        final version200Count =
            result.where((e) => e.version == Version.parse('2.0.0')).length;

        expect(version100Count, 3);
        expect(version200Count, 4);
      });
    });

    group('edge cases', () {
      test('обрабатывает пустой список источников с дополнительной проверкой',
          () {
        // Тест для дополнительной проверки edge case с пустыми источниками
        final release = createRelease(
          version: Version.parse('1.0.0'),
          sources: [], // Пустой список
        );

        final result = linker.link(release: release, sources: sources);

        expect(result, isEmpty);
      });

      test('обрабатывает глобальные источники без платформ', () {
        final customSources = [
          const UpdateSource.custom(
            UpdateSourceName.custom('empty'),
          ),
        ];

        final release = createRelease(
          version: Version.parse('1.0.0'),
          sources: [
            createSource(sourceName: const UpdateSourceName.custom('empty')),
          ],
        );

        final result = linker.link(release: release, sources: customSources);

        expect(result, isEmpty);
      });

      test('обрабатывает null customData корректно', () {
        final release = createRelease(
          version: Version.parse('1.0.0'),
          sources: [
            createSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [
                createPlatform(
                  platformName: UpdatePlatform.android,
                ),
              ],
            ),
          ],
        );

        final result = linker.link(release: release, sources: sources);

        expect(result, hasLength(1));
        expect(result[0].customData, isNull);
      });
    });
  });
}
