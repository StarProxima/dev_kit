import 'package:app_update/src/linker/update_release_linker.dart';
import 'package:app_update/src/shared/models/release/release_config.dart';
import 'package:app_update/src/shared/models/release/release_override_config.dart';
import 'package:app_update/src/shared/models/release/update_data.dart';
import 'package:app_update/src/shared/models/release_platrform/release_platrform_config.dart';
import 'package:app_update/src/shared/models/release_source/release_source_config.dart';
import 'package:app_update/src/shared/models/update_app_settings/update_app_settings_config.dart';
import 'package:app_update/src/shared/models/update_content/update_content_config.dart';
import 'package:app_update/src/shared/models/update_rule/update_rule_config.dart';
import 'package:app_update/src/shared/models/update_settings/update_settings_config.dart';
import 'package:app_update/src/shared/update_entities/update_platform.dart';
import 'package:app_update/src/shared/update_entities/update_source.dart';
import 'package:app_update/src/shared/update_entities/update_source_name.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('UpdateReleaseLinker', () {
    const linker = UpdateReleaseLinker();

    UpdateRuleConfig<UpdateContentConfig?> contentRule(String marker) =>
        UpdateRuleConfig<UpdateContentConfig?>(
          data: UpdateContentConfig(title: marker),
        );

    UpdateRuleConfig<UpdateSettingsConfig?> settingsRule(bool? shouldShow) =>
        UpdateRuleConfig<UpdateSettingsConfig?>(
          data: UpdateSettingsConfig(shouldShow: shouldShow),
        );

    UpdateRuleConfig<UpdateAppSettingsConfig?> appRule(String status) =>
        UpdateRuleConfig<UpdateAppSettingsConfig?>(
          data: UpdateAppSettingsConfig(customData: {'status': status}),
        );

    test('Инференс платформ из UpdateSource при пустых platforms в ReleaseSourceConfig', () {
      final release = ReleaseConfig(
        version: Version.parse('1.0.0'),
        date: DateTime(2024, 10, 20),
        sources: [
          const ReleaseSourceConfig(
            sourceName: UpdateSourceName.googlePlay,
            platforms: null, // явных платформ нет
          ),
        ],
      );

      final updates = linker.link(
        release: release,
        sources: const [UpdateSource.googlePlay],
      );

      // googlePlay поддерживает только android
      expect(updates.length, 1);
      expect(updates.first.platform, UpdatePlatform.android);
      expect(updates.first.source, UpdateSourceName.googlePlay);
      expect(updates.first.version, Version.parse('1.0.0'));
    });

    test('Явные платформы: порождаются апдейты для каждой платформы', () {
      final release = ReleaseConfig(
        version: Version.parse('1.0.1'),
        date: DateTime(2024, 11, 01),
        sources: [
          ReleaseSourceConfig(
            sourceName: UpdateSourceName.gitHub,
            platforms: [
              const ReleasePlatformConfig(platformName: UpdatePlatform.windows),
              const ReleasePlatformConfig(platformName: UpdatePlatform.linux),
            ],
          ),
        ],
      );

      final updates = linker.link(
        release: release,
        sources: const [UpdateSource.gitHub],
      );

      expect(
          updates.map((u) => u.platform).toSet(), {UpdatePlatform.windows, UpdatePlatform.linux});
      for (final u in updates) {
        expect(u.source, UpdateSourceName.gitHub);
        expect(u.version, Version.parse('1.0.1'));
      }
    });

    test('Приоритет оверрайдов: release < source < platform', () {
      final baseDate = DateTime(2024, 10, 01);

      final release = ReleaseConfig(
        version: Version.parse('1.0.0'),
        date: baseDate,
        sources: [
          ReleaseSourceConfig(
            sourceName: UpdateSourceName.googlePlay,
            releaseOverride: ReleaseOverrideConfig(
              version: Version(1, 1, 0),
              date: null,
              customData: {'lvl': 'source'},
            ),
            platforms: [
              ReleasePlatformConfig(
                platformName: UpdatePlatform.android,
                releaseOverride: ReleaseOverrideConfig(
                  version: Version(1, 2, 0),
                  date: null,
                  customData: {'lvl': 'platform'},
                ),
              ),
            ],
          ),
        ],
      );

      final updates = linker.link(
        release: release,
        sources: const [UpdateSource.googlePlay],
      );

      expect(updates.length, 1);
      final UpdateData u = updates.first;
      // Версия берётся из platform override (1.2.0)
      expect(u.version, Version.parse('1.2.0'));
      // Дата не переопределялась на source/platform => из release
      expect(u.date, baseDate);
      // customData из platform
      expect(u.customData, {'lvl': 'platform'});
    });

    test('Мерж правил: release + source + platform и порядок сохранён', () {
      final release = ReleaseConfig(
        version: Version.parse('2.0.0'),
        date: DateTime(2024, 12, 01),
        contentRules: [contentRule('r1')],
        settingsRules: [settingsRule(true)],
        appSettingsRules: [appRule('r')],
        sources: [
          ReleaseSourceConfig(
            sourceName: UpdateSourceName.gitHub,
            contentRules: [contentRule('s1')],
            settingsRules: [settingsRule(false)],
            appSettingsRules: [appRule('s')],
            platforms: const [
              ReleasePlatformConfig(
                platformName: UpdatePlatform.windows,
                // добавим ещё по одному правилу
                contentRules: [],
                settingsRules: [],
                appSettingsRules: [],
              ),
            ],
          ),
        ],
      );

      // Добавим платформенные правила отдельно, чтобы проверить порядок
      final withPlatformRules = ReleaseConfig(
        version: release.version,
        date: release.date,
        contentRules: release.contentRules,
        settingsRules: release.settingsRules,
        appSettingsRules: release.appSettingsRules,
        sources: [
          ReleaseSourceConfig(
            sourceName: UpdateSourceName.gitHub,
            contentRules: const [],
            settingsRules: const [],
            appSettingsRules: const [],
            platforms: [
              ReleasePlatformConfig(
                platformName: UpdatePlatform.windows,
                contentRules: [contentRule('p1')],
                settingsRules: [settingsRule(null)],
                appSettingsRules: [appRule('p')],
              ),
            ],
          ),
        ],
      );

      final updates = linker.link(
        release: withPlatformRules,
        sources: const [UpdateSource.gitHub],
      );

      final u = updates.first;
      expect(u.contentRules!.length, 3);
      expect(u.settingsRules!.length, 3);
      expect(u.appSettingsRules!.length, 3);
      // Порядок: release -> source -> platform
      expect((u.contentRules![0].data as UpdateContentConfig).title, 'r1');
      expect((u.contentRules![1].data as UpdateContentConfig).title, 's1');
      expect((u.contentRules![2].data as UpdateContentConfig).title, 'p1');
    });

    test('linkAll агрегирует обновления по нескольким релизам', () {
      final r1 = ReleaseConfig(
        version: Version.parse('1.0.0'),
        sources: const [ReleaseSourceConfig(sourceName: UpdateSourceName.googlePlay)],
      );
      final r2 = ReleaseConfig(
        version: Version.parse('1.1.0'),
        sources: const [ReleaseSourceConfig(sourceName: UpdateSourceName.gitHub)],
      );

      final all = linker.linkAll(
        releases: [r1, r2],
        sources: const [UpdateSource.googlePlay, UpdateSource.gitHub],
      );

      // r1 -> android, r2 -> несколько платформ (>=1)
      expect(all.any((e) => e.source == UpdateSourceName.googlePlay), isTrue);
      expect(all.any((e) => e.source == UpdateSourceName.gitHub), isTrue);
    });
  });
}
