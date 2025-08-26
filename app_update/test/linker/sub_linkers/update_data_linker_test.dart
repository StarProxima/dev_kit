import 'package:app_update/src/linker/sub_linkers/update_data_linker.dart';
import 'package:app_update/src/shared/entities/app_status.dart';
import 'package:app_update/src/shared/entities/update_platform.dart';
import 'package:app_update/src/shared/entities/update_source_name.dart';
import 'package:app_update/src/shared/models/global_platform/global_platform_config.dart';
import 'package:app_update/src/shared/models/global_source/global_source_config.dart';
import 'package:app_update/src/shared/models/release/update_data.dart';
import 'package:app_update/src/shared/models/update_app_settings/update_app_settings_config.dart';
import 'package:app_update/src/shared/models/update_content/update_content_config.dart';
import 'package:app_update/src/shared/models/update_rule/update_rule_config.dart';
import 'package:app_update/src/shared/models/update_rule/update_rules_container.dart';
import 'package:app_update/src/shared/models/update_settings/update_settings_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('UpdateDataLinker', () {
    const linker = UpdateDataLinker();

    // Хелперы для создания тестовых данных
    UpdateData createUpdateData({
      required Version version,
      DateTime? date,
      required UpdateSourceName sourceName,
      required UpdatePlatform platform,
      List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
      List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
      List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
      Map<String, dynamic>? customData,
    }) {
      return UpdateData(
        version: version,
        date: date ?? DateTime.now(),
        sourceName: sourceName,
        platform: platform,
        contentRules: contentRules,
        settingsRules: settingsRules,
        appSettingsRules: appSettingsRules,
        customData: customData,
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
      test('возвращает обновление без изменений если нет правил', () {
        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(),
          globalSources: [],
        );

        expect(result.version, update.version);
        expect(result.sourceName, update.sourceName);
        expect(result.platform, update.platform);
        expect(result.contentRules, isNull);
        expect(result.settingsRules, isNull);
        expect(result.appSettingsRules, isNull);
      });

      test('применяет правила из rulesContainer', () {
        final containerRule = createContentRule(title: 'Container Title');

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(
            contentRules: [containerRule],
          ),
          globalSources: [],
        );

        expect(result.contentRules, hasLength(1));
        expect(result.contentRules![0].data.title, equals('Container Title'));
      });

      test('применяет правила из глобального источника', () {
        final globalSourceRule =
            createContentRule(title: 'Global Source Title');

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          contentRules: [globalSourceRule],
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(),
          globalSources: [globalSource],
        );

        expect(result.contentRules, hasLength(1));
        expect(
            result.contentRules![0].data.title, equals('Global Source Title'));
        // Проверяем что правило было связано с источником
        expect(
          result.contentRules![0].sourceIs?.firstOrNull?.sourceName,
          equals(UpdateSourceName.googlePlay),
        );
      });

      test('применяет правила из глобальной платформы', () {
        final globalPlatformRule =
            createContentRule(title: 'Global Platform Title');

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          platforms: [
            createGlobalPlatform(
              platformName: UpdatePlatform.android,
              contentRules: [globalPlatformRule],
            ),
          ],
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(),
          globalSources: [globalSource],
        );

        expect(result.contentRules, hasLength(1));
        expect(result.contentRules![0].data.title,
            equals('Global Platform Title'));
        // Проверяем что правило было связано с источником и платформой
        expect(
          result.contentRules![0].sourceIs?.firstOrNull?.sourceName,
          equals(UpdateSourceName.googlePlay),
        );
        expect(
          result.contentRules![0].sourceIs?.firstOrNull?.platforms,
          contains(UpdatePlatform.android),
        );
      });

      test('применяет правила из самого обновления', () {
        final updateRule = createContentRule(title: 'Update Title');

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [updateRule],
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(),
          globalSources: [],
        );

        expect(result.contentRules, hasLength(1));
        expect(result.contentRules![0].data.title, equals('Update Title'));
      });

      test('мержит правила в правильном приоритете', () {
        final containerRule = createContentRule(title: 'Container');
        final globalSourceRule = createContentRule(title: 'Global Source');
        final globalPlatformRule = createContentRule(title: 'Global Platform');
        final updateRule = createContentRule(title: 'Update');

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [updateRule],
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          contentRules: [globalSourceRule],
          platforms: [
            createGlobalPlatform(
              platformName: UpdatePlatform.android,
              contentRules: [globalPlatformRule],
            ),
          ],
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(
            contentRules: [containerRule],
          ),
          globalSources: [globalSource],
        );

        expect(result.contentRules, hasLength(4));
        // Порядок: container -> globalSource -> globalPlatform -> update
        expect(result.contentRules![0].data.title, equals('Container'));
        expect(result.contentRules![1].data.title, equals('Global Source'));
        expect(result.contentRules![2].data.title, equals('Global Platform'));
        expect(result.contentRules![3].data.title, equals('Update'));
      });

      test('мержит все типы правил', () {
        final contentRule = createContentRule(title: 'Title');
        final settingsRule = createSettingsRule(shouldShow: true);
        final appSettingsRule =
            createAppSettingsRule(appStatus: AppStatus.active);

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(
            contentRules: [contentRule],
            settingsRules: [settingsRule],
            appSettingsRules: [appSettingsRule],
          ),
          globalSources: [],
        );

        expect(result.contentRules, hasLength(1));
        expect(result.settingsRules, hasLength(1));
        expect(result.appSettingsRules, hasLength(1));

        expect(result.contentRules![0].data.title, equals('Title'));
        expect(result.settingsRules![0].data.shouldShow, equals(true));
        expect(result.appSettingsRules![0].data.appStatus,
            equals(AppStatus.active));
      });

      test('игнорирует глобальные источники с несовпадающим именем', () {
        final globalSourceRule = createContentRule(title: 'Should not appear');

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.appStore, // Другой источник
          contentRules: [globalSourceRule],
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(),
          globalSources: [globalSource],
        );

        expect(result.contentRules, isNull);
      });

      test('игнорирует глобальные платформы с несовпадающим именем', () {
        final globalPlatformRule =
            createContentRule(title: 'Should not appear');

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          platforms: [
            createGlobalPlatform(
              platformName: UpdatePlatform.ios, // Другая платформа
              contentRules: [globalPlatformRule],
            ),
          ],
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(),
          globalSources: [globalSource],
        );

        expect(result.contentRules, isNull);
      });

      test('возвращает null для правил если все списки пустые', () {
        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(),
          globalSources: [],
        );

        expect(result.contentRules, isNull);
        expect(result.settingsRules, isNull);
        expect(result.appSettingsRules, isNull);
      });
    });

    group('linkAll', () {
      test('обрабатывает пустой список обновлений', () {
        final result = linker.linkAll(
          updates: [],
          rulesContainer: createRulesContainer(),
          globalSources: [],
        );

        expect(result, isEmpty);
      });

      test('применяет правила ко всем обновлениям', () {
        final containerRule = createContentRule(title: 'Container Rule');

        final updates = [
          createUpdateData(
            version: Version.parse('1.0.0'),
            sourceName: UpdateSourceName.googlePlay,
            platform: UpdatePlatform.android,
          ),
          createUpdateData(
            version: Version.parse('2.0.0'),
            sourceName: UpdateSourceName.appStore,
            platform: UpdatePlatform.ios,
          ),
        ];

        final result = linker.linkAll(
          updates: updates,
          rulesContainer: createRulesContainer(
            contentRules: [containerRule],
          ),
          globalSources: [],
        );

        expect(result, hasLength(2));
        expect(result[0].contentRules, hasLength(1));
        expect(result[1].contentRules, hasLength(1));
        expect(result[0].contentRules![0].data.title, equals('Container Rule'));
        expect(result[1].contentRules![0].data.title, equals('Container Rule'));
      });

      test('применяет разные правила к разным источникам', () {
        final googlePlayRule = createContentRule(title: 'Google Play Rule');
        final appStoreRule = createContentRule(title: 'App Store Rule');

        final updates = [
          createUpdateData(
            version: Version.parse('1.0.0'),
            sourceName: UpdateSourceName.googlePlay,
            platform: UpdatePlatform.android,
          ),
          createUpdateData(
            version: Version.parse('2.0.0'),
            sourceName: UpdateSourceName.appStore,
            platform: UpdatePlatform.ios,
          ),
        ];

        final globalSources = [
          createGlobalSource(
            sourceName: UpdateSourceName.googlePlay,
            contentRules: [googlePlayRule],
          ),
          createGlobalSource(
            sourceName: UpdateSourceName.appStore,
            contentRules: [appStoreRule],
          ),
        ];

        final result = linker.linkAll(
          updates: updates,
          rulesContainer: createRulesContainer(),
          globalSources: globalSources,
        );

        expect(result, hasLength(2));
        expect(
            result[0].contentRules![0].data.title, equals('Google Play Rule'));
        expect(result[1].contentRules![0].data.title, equals('App Store Rule'));
      });

      test('сохраняет порядок обновлений', () {
        final updates = [
          createUpdateData(
            version: Version.parse('3.0.0'),
            sourceName: UpdateSourceName.googlePlay,
            platform: UpdatePlatform.android,
          ),
          createUpdateData(
            version: Version.parse('1.0.0'),
            sourceName: UpdateSourceName.appStore,
            platform: UpdatePlatform.ios,
          ),
          createUpdateData(
            version: Version.parse('2.0.0'),
            sourceName: UpdateSourceName.gitHub,
            platform: UpdatePlatform.windows,
          ),
        ];

        final result = linker.linkAll(
          updates: updates,
          rulesContainer: createRulesContainer(),
          globalSources: [],
        );

        expect(result, hasLength(3));
        expect(result[0].version, Version.parse('3.0.0'));
        expect(result[1].version, Version.parse('1.0.0'));
        expect(result[2].version, Version.parse('2.0.0'));
      });
    });

    group('edge cases', () {
      test('обрабатывает пустой UpdateRulesContainer корректно', () {
        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
        );

        /// Создаем контейнер с полностью null полями
        final emptyContainer = UpdateRulesContainer(
          contentRules: null,
          settingsRules: null,
          appSettingsRules: null,
        );

        final result = linker.link(
          update: update,
          rulesContainer: emptyContainer,
          globalSources: [],
        );

        expect(result.contentRules, isNull);
        expect(result.settingsRules, isNull);
        expect(result.appSettingsRules, isNull);
        expect(result.version, equals(update.version));
        expect(result.sourceName, equals(update.sourceName));
        expect(result.platform, equals(update.platform));
      });

      test('обрабатывает глобальный источник без платформ', () {
        final globalSourceRule = createContentRule(title: 'Global Rule');

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          platforms: [],

          /// Пустой список платформ
          contentRules: [globalSourceRule],
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(),
          globalSources: [globalSource],
        );

        /// Должно применить правило источника, но не правило платформы
        expect(result.contentRules, hasLength(1));
        expect(result.contentRules![0].data.title, equals('Global Rule'));
      });

      test(
          'обрабатывает глобальный источник с платформами, не содержащими нужную платформу',
          () {
        final globalSourceRule = createContentRule(title: 'Source Rule');
        final globalPlatformRule = createContentRule(title: 'Platform Rule');

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,

          /// Ищем Android
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          contentRules: [globalSourceRule],
          platforms: [
            createGlobalPlatform(
              platformName: UpdatePlatform.ios,

              /// Но есть только iOS платформа
              contentRules: [globalPlatformRule],
            ),
          ],
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(),
          globalSources: [globalSource],
        );

        /// Должно применить только правило источника, но не платформы
        expect(result.contentRules, hasLength(1));
        expect(result.contentRules![0].data.title, equals('Source Rule'));

        /// Убеждаемся что правило платформы не применилось
      });

      test('обрабатывает null значения в UpdateData корректно', () {
        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: null,
          settingsRules: null,
          appSettingsRules: null,
          customData: null,
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(),
          globalSources: [],
        );

        expect(result.contentRules, isNull);
        expect(result.settingsRules, isNull);
        expect(result.appSettingsRules, isNull);
        expect(result.customData, isNull);
      });

      test(
          'корректно связывает правила с источником когда платформы фильтруются',
          () {
        final globalSourceRule = createContentRule(title: 'Source Rule');

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          contentRules: [globalSourceRule],
          platforms: [
            createGlobalPlatform(platformName: UpdatePlatform.android),
            createGlobalPlatform(platformName: UpdatePlatform.ios),
          ],
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(),
          globalSources: [globalSource],
        );

        expect(result.contentRules, hasLength(1));
        final linkedRule = result.contentRules![0];

        /// Проверяем что правило связано с источником
        expect(linkedRule.sourceIs?.firstOrNull?.sourceName,
            equals(UpdateSourceName.googlePlay));

        /// Проверяем что в список платформ включена только нужная платформа
        expect(linkedRule.sourceIs?.firstOrNull?.platforms,
            contains(UpdatePlatform.android));
      });

      test('обрабатывает множественные globalSources с одинаковым именем', () {
        final firstSourceRule = createContentRule(title: 'First Source Rule');
        final secondSourceRule = createContentRule(title: 'Second Source Rule');

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
        );

        final globalSources = [
          createGlobalSource(
            sourceName: UpdateSourceName.googlePlay,
            contentRules: [firstSourceRule],
          ),
          createGlobalSource(
            sourceName: UpdateSourceName.googlePlay,

            /// Такое же имя
            contentRules: [secondSourceRule],
          ),
        ];

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(),
          globalSources: globalSources,
        );

        /// Должен использовать только первый найденный источник (firstWhereOrNull)
        expect(result.contentRules, hasLength(1));
        expect(result.contentRules![0].data.title, equals('First Source Rule'));
      });

      test('обрабатывает глобальный источник без правил корректно', () {
        final containerRule = createContentRule(title: 'Container Rule');
        final updateRule = createContentRule(title: 'Update Rule');

        final update = createUpdateData(
          version: Version.parse('1.0.0'),
          sourceName: UpdateSourceName.googlePlay,
          platform: UpdatePlatform.android,
          contentRules: [updateRule],
        );

        final globalSource = createGlobalSource(
          sourceName: UpdateSourceName.googlePlay,
          contentRules: null,

          /// Нет правил в глобальном источнике
          platforms: [
            createGlobalPlatform(
              platformName: UpdatePlatform.android,
              contentRules: null,

              /// И в платформе тоже нет правил
            ),
          ],
        );

        final result = linker.link(
          update: update,
          rulesContainer: createRulesContainer(
            contentRules: [containerRule],
          ),
          globalSources: [globalSource],
        );

        /// Должно применить только правила из контейнера и самого update
        expect(result.contentRules, hasLength(2));
        expect(result.contentRules![0].data.title, equals('Container Rule'));
        expect(result.contentRules![1].data.title, equals('Update Rule'));
      });
    });
  });
}
