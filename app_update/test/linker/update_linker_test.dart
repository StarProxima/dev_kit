import 'package:app_update/src/linker/update_inker.dart';
import 'package:app_update/src/shared/entities/update_platform.dart';
import 'package:app_update/src/shared/entities/update_source_name.dart';
import 'package:app_update/src/shared/entities/update_version_constraint.dart';
import 'package:app_update/src/shared/models/global_platform/global_platform_config.dart';
import 'package:app_update/src/shared/models/global_source/global_source_config.dart';
import 'package:app_update/src/shared/models/release/release_config.dart';
import 'package:app_update/src/shared/models/release_platrform/release_platrform_config.dart';
import 'package:app_update/src/shared/models/release_source/release_source_config.dart';
import 'package:app_update/src/shared/models/update_app_settings/update_app_settings_config.dart';
import 'package:app_update/src/shared/models/update_content/update_content_config.dart';
import 'package:app_update/src/shared/models/update_rule/update_rule_config.dart';
import 'package:app_update/src/shared/models/update_rule/update_rules_container.dart';
import 'package:app_update/src/shared/models/update_settings/update_settings_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('UpdateLinker', () {
    const linker = UpdateLinker();

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

    ReleaseSourceConfig createReleaseSource({
      required UpdateSourceName sourceName,
      List<ReleasePlatformConfig>? platforms,
      List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
      List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
      List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
    }) {
      return ReleaseSourceConfig(
        sourceName: sourceName,
        platforms: platforms,
        contentRules: contentRules,
        settingsRules: settingsRules,
        appSettingsRules: appSettingsRules,
      );
    }

    ReleasePlatformConfig createReleasePlatform({
      required UpdatePlatform platformName,
      List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
      List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
      List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
    }) {
      return ReleasePlatformConfig(
        platformName: platformName,
        contentRules: contentRules,
        settingsRules: settingsRules,
        appSettingsRules: appSettingsRules,
      );
    }

    UpdateRulesContainer createRulesContainer({
      List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
      List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
      List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
    }) {
      return UpdateRulesContainer(
        contentRules: contentRules,
        settingsRules: settingsRules,
        appSettingsRules: appSettingsRules,
      );
    }

    GlobalSourceConfig createGlobalSource({
      required UpdateSourceName sourceName,
      List<GlobalPlatformConfig>? platforms,
      List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
      List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
      List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
    }) {
      return GlobalSourceConfig(
        sourceName: sourceName,
        platforms: platforms,
        contentRules: contentRules,
        settingsRules: settingsRules,
        appSettingsRules: appSettingsRules,
      );
    }

    GlobalPlatformConfig createGlobalPlatform({
      required UpdatePlatform platformName,
      List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
      List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
      List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
    }) {
      return GlobalPlatformConfig(
        platformName: platformName,
        contentRules: contentRules,
        settingsRules: settingsRules,
        appSettingsRules: appSettingsRules,
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

    group('link', () {
      test('возвращает пустой список для релиза без источников', () {
        final release = createRelease(
          version: Version.parse('1.0.0'),
        );

        final result = linker.link(
          release: release,
          rulesContainer: createRulesContainer(),
          globalSources: [],
        );

        expect(result, isEmpty);
      });

      test('создает UpdateData из релиза с источником и платформой', () {
        final release = createRelease(
          version: Version.parse('1.0.0'),
          date: DateTime(2024, 10, 20),
          sources: [
            createReleaseSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [
                createReleasePlatform(platformName: UpdatePlatform.android),
              ],
            ),
          ],
        );

        final globalSources = [
          createGlobalSource(sourceName: UpdateSourceName.googlePlay),
        ];

        final result = linker.link(
          release: release,
          rulesContainer: createRulesContainer(),
          globalSources: globalSources,
        );

        expect(result, hasLength(1));
        expect(result[0].version, Version.parse('1.0.0'));
        expect(result[0].date, DateTime(2024, 10, 20));
        expect(result[0].sourceName, UpdateSourceName.googlePlay);
        expect(result[0].platform, UpdatePlatform.android);
      });

      test('интегрирует правила из релиза и глобальных источников', () {
        final releaseRule = createContentRule(title: 'Release Rule');
        final globalSourceRule = createContentRule(title: 'Global Source Rule');
        final containerRule = createContentRule(title: 'Container Rule');

        final release = createRelease(
          version: Version.parse('1.0.0'),
          contentRules: [releaseRule],
          sources: [
            createReleaseSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [
                createReleasePlatform(platformName: UpdatePlatform.android),
              ],
            ),
          ],
        );

        final globalSources = [
          createGlobalSource(
            sourceName: UpdateSourceName.googlePlay,
            contentRules: [globalSourceRule],
          ),
        ];

        final result = linker.link(
          release: release,
          rulesContainer: createRulesContainer(
            contentRules: [containerRule],
          ),
          globalSources: globalSources,
        );

        expect(result, hasLength(1));
        expect(result[0].contentRules, hasLength(3));

        // Проверяем порядок: container -> globalSource -> release
        expect(result[0].contentRules![0].data.title, equals('Container Rule'));
        expect(result[0].contentRules![1].data.title,
            equals('Global Source Rule'));
        expect(result[0].contentRules![2].data.title, equals('Release Rule'));

        // Проверяем что правила связаны с версией релиза
        expect(
          result[0].contentRules![2].versions,
          contains(UpdateVersionConstraint(release.version)),
        );
      });

      test('создает несколько UpdateData для релиза с несколькими платформами',
          () {
        final release = createRelease(
          version: Version.parse('1.0.0'),
          sources: [
            createReleaseSource(
              sourceName: UpdateSourceName.appStore,
            ),
          ],
        );

        final globalSources = [
          createGlobalSource(
            sourceName: UpdateSourceName.appStore,
            platforms: [
              createGlobalPlatform(platformName: UpdatePlatform.ios),
              createGlobalPlatform(platformName: UpdatePlatform.macos),
            ],
          ),
        ];

        final result = linker.link(
          release: release,
          rulesContainer: createRulesContainer(),
          globalSources: globalSources,
        );

        expect(result, hasLength(2));
        expect(result.map((e) => e.platform),
            containsAll([UpdatePlatform.ios, UpdatePlatform.macos]));
      });

      test('применяет правила платформы с правильным приоритетом', () {
        final releaseRule = createContentRule(title: 'Release');
        final sourceRule = createContentRule(title: 'Source');
        final platformRule = createContentRule(title: 'Platform');
        final globalSourceRule = createContentRule(title: 'Global Source');
        final globalPlatformRule = createContentRule(title: 'Global Platform');
        final containerRule = createContentRule(title: 'Container');

        final release = createRelease(
          version: Version.parse('1.0.0'),
          contentRules: [releaseRule],
          sources: [
            createReleaseSource(
              sourceName: UpdateSourceName.googlePlay,
              contentRules: [sourceRule],
              platforms: [
                createReleasePlatform(
                  platformName: UpdatePlatform.android,
                  contentRules: [platformRule],
                ),
              ],
            ),
          ],
        );

        final globalSources = [
          createGlobalSource(
            sourceName: UpdateSourceName.googlePlay,
            contentRules: [globalSourceRule],
            platforms: [
              createGlobalPlatform(
                platformName: UpdatePlatform.android,
                contentRules: [globalPlatformRule],
              ),
            ],
          ),
        ];

        final result = linker.link(
          release: release,
          rulesContainer: createRulesContainer(
            contentRules: [containerRule],
          ),
          globalSources: globalSources,
        );

        expect(result, hasLength(1));
        expect(result[0].contentRules, hasLength(6));

        // Порядок: container -> globalSource -> globalPlatform -> release -> source -> platform
        expect(result[0].contentRules![0].data.title, equals('Container'));
        expect(result[0].contentRules![1].data.title, equals('Global Source'));
        expect(
            result[0].contentRules![2].data.title, equals('Global Platform'));
        expect(result[0].contentRules![3].data.title, equals('Release'));
        expect(result[0].contentRules![4].data.title, equals('Source'));
        expect(result[0].contentRules![5].data.title, equals('Platform'));
      });
    });

    group('linkAll', () {
      test('обрабатывает пустой список релизов', () {
        final result = linker.linkAll(
          releases: [],
          rulesContainer: createRulesContainer(),
          globalSources: [],
        );

        expect(result, isEmpty);
      });

      test('создает UpdateData для нескольких релизов', () {
        final releases = [
          createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createReleaseSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createReleasePlatform(platformName: UpdatePlatform.android),
                ],
              ),
            ],
          ),
          createRelease(
            version: Version.parse('2.0.0'),
            sources: [
              createReleaseSource(
                sourceName: UpdateSourceName.appStore,
                platforms: [
                  createReleasePlatform(platformName: UpdatePlatform.ios),
                ],
              ),
            ],
          ),
        ];

        final globalSources = [
          createGlobalSource(sourceName: UpdateSourceName.googlePlay),
          createGlobalSource(sourceName: UpdateSourceName.appStore),
        ];

        final result = linker.linkAll(
          releases: releases,
          rulesContainer: createRulesContainer(),
          globalSources: globalSources,
        );

        expect(result, hasLength(2));
        expect(result[0].version, Version.parse('1.0.0'));
        expect(result[1].version, Version.parse('2.0.0'));
        expect(result[0].sourceName, UpdateSourceName.googlePlay);
        expect(result[1].sourceName, UpdateSourceName.appStore);
      });

      test('применяет глобальные правила ко всем релизам', () {
        final globalRule = createContentRule(title: 'Global Rule');
        final containerRule = createContentRule(title: 'Container Rule');

        final releases = [
          createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createReleaseSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createReleasePlatform(platformName: UpdatePlatform.android),
                ],
              ),
            ],
          ),
          createRelease(
            version: Version.parse('2.0.0'),
            sources: [
              createReleaseSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createReleasePlatform(platformName: UpdatePlatform.android),
                ],
              ),
            ],
          ),
        ];

        final globalSources = [
          createGlobalSource(
            sourceName: UpdateSourceName.googlePlay,
            contentRules: [globalRule],
          ),
        ];

        final result = linker.linkAll(
          releases: releases,
          rulesContainer: createRulesContainer(
            contentRules: [containerRule],
          ),
          globalSources: globalSources,
        );

        expect(result, hasLength(2));

        for (final update in result) {
          expect(update.contentRules, hasLength(2));
          expect(update.contentRules![0].data.title, equals('Container Rule'));
          expect(update.contentRules![1].data.title, equals('Global Rule'));
        }
      });

      test('сохраняет порядок релизов в результате', () {
        final releases = [
          createRelease(
            version: Version.parse('3.0.0'),
            sources: [
              createReleaseSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createReleasePlatform(platformName: UpdatePlatform.android),
                ],
              ),
            ],
          ),
          createRelease(
            version: Version.parse('1.0.0'),
            sources: [
              createReleaseSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createReleasePlatform(platformName: UpdatePlatform.android),
                ],
              ),
            ],
          ),
          createRelease(
            version: Version.parse('2.0.0'),
            sources: [
              createReleaseSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createReleasePlatform(platformName: UpdatePlatform.android),
                ],
              ),
            ],
          ),
        ];

        final globalSources = [
          createGlobalSource(sourceName: UpdateSourceName.googlePlay),
        ];

        final result = linker.linkAll(
          releases: releases,
          rulesContainer: createRulesContainer(),
          globalSources: globalSources,
        );

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
              createReleaseSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createReleasePlatform(platformName: UpdatePlatform.android),
                ],
              ),
              createReleaseSource(
                sourceName: UpdateSourceName.appStore,
              ),
            ],
          ),
        ];

        final globalSources = [
          createGlobalSource(
            sourceName: UpdateSourceName.googlePlay,
          ),
          createGlobalSource(
            sourceName: UpdateSourceName.appStore,
            platforms: [
              createGlobalPlatform(platformName: UpdatePlatform.ios),
              createGlobalPlatform(platformName: UpdatePlatform.macos),
            ],
          ),
        ];

        final result = linker.linkAll(
          releases: releases,
          rulesContainer: createRulesContainer(),
          globalSources: globalSources,
        );

        // 1 релиз: 1 Android (Google Play) + 2 (iOS + macOS для App Store) = 3
        expect(result, hasLength(3));
        expect(
            result.map((e) => e.platform),
            containsAll([
              UpdatePlatform.android,
              UpdatePlatform.ios,
              UpdatePlatform.macos
            ]));
        expect(
            result.where((e) => e.version == Version.parse('1.0.0')).length, 3);
      });

      test('пропускает релизы без источников', () {
        final releases = [
          createRelease(
            version: Version.parse('1.0.0'),
          ),
          createRelease(
            version: Version.parse('2.0.0'),
            sources: [
              createReleaseSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [
                  createReleasePlatform(platformName: UpdatePlatform.android),
                ],
              ),
            ],
          ),
        ];

        final globalSources = [
          createGlobalSource(sourceName: UpdateSourceName.googlePlay),
        ];

        final result = linker.linkAll(
          releases: releases,
          rulesContainer: createRulesContainer(),
          globalSources: globalSources,
        );

        expect(result, hasLength(1));
        expect(result[0].version, Version.parse('2.0.0'));
      });
    });
  });
}
