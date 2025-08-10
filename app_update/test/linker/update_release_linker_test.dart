import 'package:app_update/src/linker/update_release_linker.dart';
import 'package:app_update/src/shared/models/release/release_config.dart';
import 'package:app_update/src/shared/models/release/release_override_config.dart';
import 'package:app_update/src/shared/models/release_platrform/release_platrform_config.dart';
import 'package:app_update/src/shared/models/release_source/release_source_config.dart';
import 'package:app_update/src/shared/models/update_app_settings/update_app_settings_config.dart';
import 'package:app_update/src/shared/models/update_content/update_content_config.dart';
import 'package:app_update/src/shared/models/update_rule/update_rule_config.dart';
import 'package:app_update/src/shared/models/update_settings/update_settings_config.dart';
import 'package:app_update/src/shared/update_entities/app_status.dart';
import 'package:app_update/src/shared/update_entities/update_platform.dart';
import 'package:app_update/src/shared/update_entities/update_source.dart';
import 'package:app_update/src/shared/update_entities/update_source_name.dart';
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
      Version? version,
      DateTime? date,
      List<ReleaseSourceConfig>? sources,
      List<UpdateRuleConfig<UpdateContentConfig?>>? contentRules,
      List<UpdateRuleConfig<UpdateSettingsConfig?>>? settingsRules,
      List<UpdateRuleConfig<UpdateAppSettingsConfig?>>? appSettingsRules,
      Map<String, dynamic>? customData,
    }) {
      return ReleaseConfig(
        version: version,
        date: date,
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
      List<UpdateRuleConfig<UpdateContentConfig?>>? contentRules,
      List<UpdateRuleConfig<UpdateSettingsConfig?>>? settingsRules,
      List<UpdateRuleConfig<UpdateAppSettingsConfig?>>? appSettingsRules,
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
      List<UpdateRuleConfig<UpdateContentConfig?>>? contentRules,
      List<UpdateRuleConfig<UpdateSettingsConfig?>>? settingsRules,
      List<UpdateRuleConfig<UpdateAppSettingsConfig?>>? appSettingsRules,
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
      test('возвращает пустой список если sources == null', () {
        final release = createRelease(
          version: Version.parse('1.0.0'),
          sources: null,
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

      test('пропускает источники которых нет в списке доступных', () {
        final release = createRelease(
          version: Version.parse('1.0.0'),
          sources: [
            createSource(sourceName: const UpdateSourceName.custom('unknown')),
          ],
        );

        final result = linker.link(release: release, sources: sources);

        expect(result, isEmpty);
      });

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
        expect(result[0].source, UpdateSourceName.googlePlay);
        expect(result[0].platform, UpdatePlatform.android);
      });

      test('создает платформы из UpdateSource.platforms когда platforms == null', () {
        final release = createRelease(
          version: Version.parse('1.0.0'),
          sources: [
            createSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: null, // Должны создаться из UpdateSource.platforms
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
              platforms: null, // iOS и macOS из UpdateSource.platforms
            ),
          ],
        );

        final result = linker.link(release: release, sources: sources);

        // App Store поддерживает iOS и macOS
        expect(result, hasLength(2));
        expect(
            result.map((e) => e.platform), containsAll([UpdatePlatform.ios, UpdatePlatform.macos]));
      });

      test('применяет переопределения версии из ReleaseOverrideConfig', () {
        final overrideVersion = Version.parse('2.0.0');
        final release = createRelease(
          version: Version.parse('1.0.0'),
          sources: [
            createSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [createPlatform(platformName: UpdatePlatform.android)],
              releaseOverride: ReleaseOverrideConfig(version: overrideVersion),
            ),
          ],
        );

        final result = linker.link(release: release, sources: sources);

        expect(result, hasLength(1));
        expect(result[0].version, overrideVersion);
      });

      test('применяет переопределения даты из ReleaseOverrideConfig', () {
        final overrideDate = DateTime(2024, 12, 25);
        final release = createRelease(
          version: Version.parse('1.0.0'),
          date: DateTime(2024, 10, 20),
          sources: [
            createSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [createPlatform(platformName: UpdatePlatform.android)],
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
                  releaseOverride: ReleaseOverrideConfig(version: platformVersion),
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

      test('объединяет правила в правильном приоритете', () {
        final releaseRule = createContentRule(title: 'Release Title');
        final sourceRule = createContentRule(description: 'Source Description');
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
        expect(result[0].contentRules![0], same(releaseRule));
        expect(result[0].contentRules![1], same(sourceRule));
        expect(result[0].contentRules![2], same(platformRule));
      });

      test('объединяет все типы правил', () {
        final contentRule = createContentRule(title: 'Title');
        final settingsRule = createSettingsRule(shouldShow: true);
        final appSettingsRule = createAppSettingsRule(appStatus: AppStatus.active);

        final release = createRelease(
          version: Version.parse('1.0.0'),
          contentRules: [contentRule],
          settingsRules: [settingsRule],
          appSettingsRules: [appSettingsRule],
          sources: [
            createSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [createPlatform(platformName: UpdatePlatform.android)],
            ),
          ],
        );

        final result = linker.link(release: release, sources: sources);

        expect(result, hasLength(1));
        expect(result[0].contentRules, contains(contentRule));
        expect(result[0].settingsRules, contains(settingsRule));
        expect(result[0].appSettingsRules, contains(appSettingsRule));
      });

      test('объединяет кастомные данные в правильном приоритете', () {
        final release = createRelease(
          version: Version.parse('1.0.0'),
          customData: {'release': 'data', 'shared': 'release'},
          sources: [
            createSource(
              sourceName: UpdateSourceName.googlePlay,
              customData: {'source': 'data', 'shared': 'source'},
              platforms: [
                createPlatform(
                  platformName: UpdatePlatform.android,
                  customData: {'platform': 'data', 'shared': 'platform'},
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
        expect(customData['platform'], 'data');
        expect(customData['shared'], 'platform'); // платформа имеет приоритет
      });

      test('использует Version.none если версия не задана', () {
        final release = createRelease(
          version: null,
          sources: [
            createSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [createPlatform(platformName: UpdatePlatform.android)],
            ),
          ],
        );

        final result = linker.link(release: release, sources: sources);

        expect(result, hasLength(1));
        expect(result[0].version, Version.none);
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
                platforms: [createPlatform(platformName: UpdatePlatform.android)],
              ),
            ],
          ),
          createRelease(
            version: Version.parse('1.1.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.appStore,
                platforms: null, // iOS и macOS
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
            sources: null,
          ),
          createRelease(
            version: Version.parse('1.1.0'),
            sources: [
              createSource(
                sourceName: UpdateSourceName.googlePlay,
                platforms: [createPlatform(platformName: UpdatePlatform.android)],
              ),
            ],
          ),
        ];

        final result = linker.linkAll(releases: releases, sources: sources);

        expect(result, hasLength(1));
        expect(result[0].version, Version.parse('1.1.0'));
      });
    });
  });
}
