import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

import '../helpers/linker_helper.dart';

void main() {
  group('UpdateLinker', () {
    const linker = UpdateLinker();

    group('linkAllConfigs', () {
      test('обрабатывает пустой список конфигураций', () {
        final result = linker.linkAllConfigs([]);

        expect(result, isEmpty);
      });

      test('обрабатывает одну конфигурацию без релизов', () {
        final config = createUpdateConfig();

        final result = linker.linkAllConfigs([config]);

        expect(result, isEmpty);
      });

      test('обрабатывает одну конфигурацию с релизом', () {
        final release = createRelease(
          version: Version.parse('1.0.0'),
          sources: [
            createReleaseSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [
                createReleasePlatform(platformName: UpdatePlatform.android),
              ],
            ),
          ],
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          platforms: [
            createGlobalPlatform(platformName: UpdatePlatform.android),
          ],
        );

        final config = createUpdateConfig(
          sources: [globalSource],
          releases: [release],
        );

        final result = linker.linkAllConfigs([config]);

        expect(result, hasLength(1));
        expect(result[0].version, Version.parse('1.0.0'));
      });

      test('объединяет правила из нескольких конфигураций', () {
        final contentRule1 = createContentRule(title: 'Title 1');
        final contentRule2 = createContentRule(title: 'Title 2');

        final release1 = createRelease(
          version: Version.parse('1.0.0'),
          contentRules: [contentRule1],
          sources: [
            createReleaseSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [
                createReleasePlatform(platformName: UpdatePlatform.android),
              ],
            ),
          ],
        );

        final release2 = createRelease(
          version: Version.parse('2.0.0'),
          contentRules: [contentRule2],
          sources: [
            createReleaseSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [
                createReleasePlatform(platformName: UpdatePlatform.android),
              ],
            ),
          ],
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          platforms: [
            createGlobalPlatform(platformName: UpdatePlatform.android),
          ],
        );

        final config1 = createUpdateConfig(
          contentRules: [contentRule1],
          sources: [globalSource],
          releases: [release1],
        );

        final config2 = createUpdateConfig(
          contentRules: [contentRule2],
          sources: [globalSource],
          releases: [release2],
        );

        final result = linker.linkAllConfigs([config1, config2]);

        expect(result, hasLength(2));
        expect(result.map((r) => r.version.toString()).toList(),
            ['1.0.0', '2.0.0']);
      });

      test('объединяет источники из разных конфигураций', () {
        final googlePlaySource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          platforms: [
            createGlobalPlatform(platformName: UpdatePlatform.android),
          ],
        );

        final appStoreSource = createGlobalSource(
          sourceName: UpdateSourceName.appStore,
          platforms: [
            createGlobalPlatform(platformName: UpdatePlatform.ios),
          ],
        );

        final release = createRelease(
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
              platforms: [
                createReleasePlatform(platformName: UpdatePlatform.ios),
              ],
            ),
          ],
        );

        final config1 = createUpdateConfig(
          sources: [googlePlaySource],
          releases: [release],
        );

        final config2 = createUpdateConfig(
          sources: [appStoreSource],
          releases: [release],
        );

        final result = linker.linkAllConfigs([config1, config2]);

        expect(result,
            hasLength(4)); // 2 config * 2 platforms per release = 4 results
        expect(result.any((r) => r.version == Version.parse('1.0.0')), isTrue);
      });

      test('обрабатывает конфигурации с null полями', () {
        final config1 = createUpdateConfig();
        final config2 = createUpdateConfig();

        final result = linker.linkAllConfigs([config1, config2]);

        expect(result, isEmpty);
      });

      test('обрабатывает конфигурации с пустыми списками', () {
        final config1 = createUpdateConfig(contentRules: []);
        final config2 = createUpdateConfig(settingsRules: []);

        final result = linker.linkAllConfigs([config1, config2]);

        expect(result, isEmpty);
      });

      test('объединяет все типы правил из конфигураций', () {
        final contentRule = createContentRule(title: 'Content');
        final settingsRule = createSettingsRule(shouldShow: true);
        final appSettingsRule =
            createAppSettingsRule(appStatus: AppStatus.active);

        final release = createRelease(
          version: Version.parse('1.0.0'),
          contentRules: [contentRule],
          settingsRules: [settingsRule],
          appSettingsRules: [appSettingsRule],
          sources: [
            createReleaseSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [
                createReleasePlatform(platformName: UpdatePlatform.android),
              ],
            ),
          ],
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          platforms: [
            createGlobalPlatform(platformName: UpdatePlatform.android),
          ],
        );

        final config = createUpdateConfig(
          contentRules: [contentRule],
          settingsRules: [settingsRule],
          appSettingsRules: [appSettingsRule],
          sources: [globalSource],
          releases: [release],
        );

        final result = linker.linkAllConfigs([config]);

        expect(result, hasLength(1));
        expect(result[0].version, Version.parse('1.0.0'));
      });

      test('объединяет релизы и сортирует по версии', () {
        final release1 = createRelease(
          version: Version.parse('1.0.0'),
          sources: [
            createReleaseSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [
                createReleasePlatform(platformName: UpdatePlatform.android),
              ],
            ),
          ],
        );

        final release2 = createRelease(
          version: Version.parse('2.0.0'),
          sources: [
            createReleaseSource(
              sourceName: UpdateSourceName.googlePlay,
              platforms: [
                createReleasePlatform(platformName: UpdatePlatform.android),
              ],
            ),
          ],
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          platforms: [
            createGlobalPlatform(platformName: UpdatePlatform.android),
          ],
        );

        final config1 = createUpdateConfig(
          sources: [globalSource],
          releases: [release2], // Больший версия первая
        );

        final config2 = createUpdateConfig(
          sources: [globalSource],
          releases: [release1], // Меньшая версия вторая
        );

        final result = linker.linkAllConfigs([config1, config2]);

        expect(result, hasLength(2));
        // Результат должен быть отсортирован по версии
        expect(result[0].version, Version.parse('2.0.0'));
      });
    });
  });
}
