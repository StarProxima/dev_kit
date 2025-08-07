import 'package:app_update/src/parser/sub_parsers/update_rule_config/update_rule_config.dart';
import 'package:app_update/src/rule_resolver/models/update_content_data.dart';
import 'package:app_update/src/rule_resolver/models/update_search_data.dart';
import 'package:app_update/src/rule_resolver/update_rule_resolver.dart';
import 'package:app_update/src/shared/app_status.dart';
import 'package:app_update/src/shared/update_date.dart';
import 'package:app_update/src/shared/update_locale.dart';
import 'package:app_update/src/shared/update_platform.dart';
import 'package:app_update/src/shared/update_source.dart';
import 'package:app_update/src/shared/update_version_constraint.dart';
import 'package:app_update/src/shared/update_view_target.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('UpdateRuleResolver', () {
    const resolver = UpdateRuleResolver();

    UpdateSearchData search({
      UpdateViewTarget target = UpdateViewTarget.card,
      UpdateLocale? locale,
      List<UpdateSource>? sources,
      String version = '1.0.0',
      AppStatus? appStatus,
      UpdatePlatform? platform,
      DateTime? currentDate,
      DateTime? localReleaseDate,
      DateTime? updateReleaseDate,
      double segmentationPointer = 0.0,
      double rolloutPointer = 0.0,
      Map<String, dynamic>? custom,
    }) {
      return UpdateSearchData(
        platform: platform ?? UpdatePlatform.android,
        sources: sources ?? const [UpdateSource.googlePlay],
        localVersion: Version.parse(version),
        displayTarget: target,
        appStatus: appStatus,
        locale: locale ?? const UpdateLocale(Locale('ru')),
        currentDate: currentDate ?? DateTime(2024, 10, 20, 12),
        localReleaseDate: localReleaseDate,
        updateReleaseDate: updateReleaseDate,
        segmentationPointer: segmentationPointer,
        rolloutPointer: rolloutPointer,
        customData: custom,
      );
    }

    UpdateRuleConfig<UpdateContentData> rule({
      List<UpdateViewTarget> targets = const [UpdateViewTarget.any],
      List<UpdateLocale> locales = const [UpdateLocale.any],
      List<UpdateSource> sources = const [UpdateSource.any],
      List<UpdateVersionConstraint> versions = const [
        UpdateVersionConstraint.any
      ],
      List<AppStatus> statuses = const [AppStatus.any],
      UpdateDate date = UpdateDate.any,
      Duration? delay,
      Duration? rollout,
      double? segmentation,
      String? title,
      String? description,
      Map<String, dynamic>? custom,
    }) {
      return UpdateRuleConfig<UpdateContentData>.byRequired(
        appStatuses: statuses,
        locales: locales,
        viewTargets: targets,
        versions: versions,
        sources: sources,
        date: date,
        delay: delay,
        rollout: rollout,
        segmentationPercent: segmentation,
        data: UpdateContentData(
          title: title,
          description: description,
          releaseNotesTitle: null,
          releaseNotes: null,
          skipButton: null,
          postponeButton: null,
          updateButton: null,
          customData: null,
        ),
        customData: custom,
      );
    }

    test('Простое совпадение по таргету/локали/источнику/версии', () {
      final rules = [
        rule(
          targets: const [UpdateViewTarget.card],
          locales: [const UpdateLocale(Locale('ru'))],
          sources: const [UpdateSource.googlePlay],
          versions: [
            UpdateVersionConstraint(VersionConstraint.parse('>=1.0.0 <2.0.0'))
          ],
          title: 'A',
        ),
      ];

      final res = resolver.resolve(searchData: search(), rules: rules);

      expect(res.title, 'A');
    });

    test('Приоритет последнего правила (мердж)', () {
      final rules = [
        rule(title: 'A', description: 'd1'),
        rule(title: 'B'),
      ];

      final res = resolver.resolve(searchData: search(), rules: rules);

      expect(res.title, 'B');
      expect(res.description, 'd1');
    });

    test('Сегментация: пропускает при pointer > threshold', () {
      final rules = [
        rule(segmentation: 10, title: 'A'), // порог 0.1
      ];

      // pointer 0.2 > 0.1 => правило не подходит
      expect(
        () => resolver.resolve(
            searchData: search(segmentationPointer: 0.2), rules: rules),
        throwsA(isA<Exception>()),
      );
    });

    test('Delay: применяется только после delay', () {
      final baseDate = DateTime(2024, 10, 20, 12);
      final rules = [
        rule(
            date: UpdateDate(baseDate),
            delay: const Duration(hours: 24),
            title: 'A'),
      ];

      // now до (base+24h) — правило не подходит
      expect(
        () => resolver.resolve(
          searchData:
              search(currentDate: baseDate.add(const Duration(hours: 23))),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );

      // now после (base+24h)
      final res = resolver.resolve(
        searchData:
            search(currentDate: baseDate.add(const Duration(hours: 25))),
        rules: rules,
      );
      expect(res.title, 'A');
    });

    test('Rollout: pointer должен быть <= прогрессу выката', () {
      final baseDate = DateTime(2024, 10, 20, 12);
      final rules = [
        rule(
            date: UpdateDate(baseDate),
            rollout: const Duration(hours: 100),
            title: 'A'),
      ];

      // Через 10 часов, прогресс ~0.1 — pointer 0.2 не проходит
      expect(
        () => resolver.resolve(
          searchData: search(
            currentDate: baseDate.add(const Duration(hours: 10)),
            rolloutPointer: 0.2,
          ),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );

      // pointer 0.05 проходит
      final res = resolver.resolve(
        searchData: search(
          currentDate: baseDate.add(const Duration(hours: 10)),
          rolloutPointer: 0.05,
        ),
        rules: rules,
      );
      expect(res.title, 'A');
    });

    test('Платформы и customData + dynamic dates (local/update release)', () {
      final baseDate = DateTime(2024, 10, 20, 12);

      final rules = [
        // 1. База, работает везде, задаём заглушки
        rule(title: 'base', description: 'd0', custom: const {'env': 'prod'}),

        // 2. Источник googlePlay + платформа android => мердж описания
        rule(
          sources: const [UpdateSource.googlePlay],
          targets: const [UpdateViewTarget.card],
          versions: [
            UpdateVersionConstraint(VersionConstraint.parse('>=1.0.0'))
          ],
          description: 'android-store',
        ),

        // 3. Сегментация 100% + rollout 48h, pointer 0.5 через 24h — не пройдёт
        rule(
          date: UpdateDate.updateReleaseDate,
          rollout: const Duration(hours: 48),
          segmentation: 100,
          title: 'segmented',
        ),

        // 4. Delay от localReleaseDate: через 20h не пройдёт, через 30h — пройдёт
        rule(
          date: UpdateDate.localReleaseDate,
          delay: const Duration(hours: 24),
          title: 'after-delay',
        ),
      ];

      // Первый проход — 20h после updateRelease, rolloutPointer 0.6,
      // target=screen (чтобы правило 2 не прошло), custom=null (чтобы правило 1 не прошло)
      expect(
        () => resolver.resolve(
          searchData: search(
            target: UpdateViewTarget.screen,
            currentDate: baseDate.add(const Duration(hours: 20)),
            rolloutPointer: 0.6,
            localReleaseDate: baseDate,
            updateReleaseDate: baseDate,
            sources: const [UpdateSource.googlePlay],
          ),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );

      // Второй проход — 30h после localReleaseDate -> сработает правило 4 (delay 24h)
      final res2 = resolver.resolve(
        searchData: search(
          currentDate: baseDate.add(const Duration(hours: 30)),
          rolloutPointer: 0.5,
          localReleaseDate: baseDate,
          updateReleaseDate: baseDate,
          sources: const [UpdateSource.googlePlay],
          // теперь передаём customData для базового правила
          custom: const {
            'ENV': 'PROD',
            'meta': {
              'tags': ['alpha', 'beta']
            }
          },
        ),
        rules: rules,
      );
      expect(res2.title, 'after-delay');
      expect(res2.description, 'android-store');
    });

    group('customData matching', () {
      test('Пустое правило или null в правиле — всегда true', () {
        final rules = [
          rule(title: 'ok'),
        ];

        final res = resolver.resolve(
          searchData: search(),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test('rule map vs search map: кейсы ключей/значений игнорируются', () {
        final rules = [
          rule(custom: const {'ENV': 'PROD'}, title: 'ok'),
        ];

        final res = resolver.resolve(
          searchData: search(custom: const {'env': 'prod'}),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test("rule 'any' как строка — всегда true", () {
        final rules = [
          rule(custom: const {'stage': 'ANY'}, title: 'ok'),
        ];

        final res = resolver.resolve(
          searchData: search(custom: const {'stage': 'qa'}),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test('nested map: глубокое сравнение', () {
        final rules = [
          rule(custom: const {
            'meta': {
              'Flag': 'On',
            }
          }, title: 'ok'),
        ];

        final res = resolver.resolve(
          searchData: search(custom: const {
            'META': {
              'fLaG': 'on',
            }
          }),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test('list any-of: достаточно совпадения хотя бы одного элемента', () {
        final rules = [
          rule(custom: const {
            'tags': ['alpha', 'beta']
          }, title: 'ok'),
        ];

        final res = resolver.resolve(
          searchData: search(custom: const {
            'tags': ['gamma', 'BETA']
          }),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test("list 'any' в правиле — всегда true", () {
        final rules = [
          rule(custom: const {
            'tags': ['any']
          }, title: 'ok'),
        ];

        final res = resolver.resolve(
          searchData: search(custom: const {'tags': []}),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test('scalar vs list: совпадает если элемент найден в списке', () {
        final rules = [
          rule(custom: const {'tag': 'Alpha'}, title: 'ok'),
        ];

        final res = resolver.resolve(
          searchData: search(custom: const {
            'tag': ['alpha', 'beta']
          }),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test('list vs scalar: достаточно совпадения одного элемента', () {
        final rules = [
          rule(custom: const {
            'tag': ['ALPHA', 'BETA']
          }, title: 'ok'),
        ];

        final res = resolver.resolve(
          searchData: search(custom: const {'tag': 'beta'}),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test('числа и булевы сравниваются по точному совпадению', () {
        // Позитивные
        var rules = [
          rule(custom: const {'n': 5, 'b': true}, title: 'ok'),
        ];
        final res = resolver.resolve(
          searchData: search(custom: const {'n': 5, 'b': true}),
          rules: rules,
        );
        expect(res.title, 'ok');

        // Негативные
        rules = [
          rule(custom: const {'n': 5}, title: 'bad'),
        ];
        expect(
          () => resolver.resolve(
              searchData: search(custom: const {'n': '5'}), rules: rules),
          throwsA(isA<Exception>()),
        );

        rules = [
          rule(custom: const {'b': true}, title: 'bad'),
        ];
        expect(
          () => resolver.resolve(
              searchData: search(custom: const {'b': false}), rules: rules),
          throwsA(isA<Exception>()),
        );
      });

      test('list any-of: числа', () {
        final rules = [
          rule(custom: const {
            'nums': [5, 7]
          }, title: 'ok'),
        ];

        final res = resolver.resolve(
          searchData: search(custom: const {
            'nums': [7]
          }),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test('negative: отсутствие ключа в поиске — false', () {
        final rules = [
          rule(custom: const {'env': 'prod'}, title: 'bad'),
        ];

        expect(
          () => resolver.resolve(
              searchData: search(custom: const {}), rules: rules),
          throwsA(isA<Exception>()),
        );
      });

      test('negative: список не содержит ни одного совпадения', () {
        final rules = [
          rule(custom: const {
            'tags': ['alpha']
          }, title: 'bad'),
        ];

        expect(
          () => resolver.resolve(
              searchData: search(custom: const {
                'tags': ['beta']
              }),
              rules: rules),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('sources/platforms matching', () {
      test('rule platforms == null берёт платформы из search source', () {
        const ruleSource = UpdateSource.custom('storeX');
        const searchSource =
            UpdateSource.custom('storeX', platforms: [UpdatePlatform.ios]);

        final rules = [
          rule(sources: [ruleSource], title: 'ok'),
        ];

        final res = resolver.resolve(
          searchData: search(
            sources: [searchSource],
            platform: UpdatePlatform.ios,
            // Платформа iOS должна сматчиться через глобальный source
            locale: const UpdateLocale(Locale('ru')),
          ),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test('rule platforms == [] отключает правило', () {
        const ruleSource = UpdateSource.custom('storeX', platforms: []);
        const searchSource =
            UpdateSource.custom('storeX', platforms: [UpdatePlatform.ios]);

        final rules = [
          rule(sources: [ruleSource], title: 'bad'),
        ];

        expect(
          () => resolver.resolve(
              searchData: search(sources: [searchSource]), rules: rules),
          throwsA(isA<Exception>()),
        );
      });

      test('UpdateSource.any в правиле матчится без ограничений', () {
        final rules = [
          rule(title: 'ok'),
        ];

        final res = resolver.resolve(
          searchData: search(sources: const [UpdateSource.googlePlay]),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test('Mismatch платформы — правило не подходит', () {
        final rules = [
          rule(sources: const [UpdateSource.googlePlay], title: 'bad'),
        ];

        // googlePlay поддерживает android; задаём платформу iOS
        expect(
          () => resolver.resolve(
            searchData: search(
              sources: const [UpdateSource.googlePlay],
              platform: UpdatePlatform.ios,
              // принудительно считаем платформу iOS
              locale: const UpdateLocale(Locale('ru')),
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('rule platforms == [any] допускает любую платформу', () {
        const ruleSource =
            UpdateSource.custom('storeX', platforms: [UpdatePlatform.any]);
        const searchSource =
            UpdateSource.custom('storeX', platforms: [UpdatePlatform.windows]);

        final rules = [
          rule(sources: [ruleSource], title: 'ok'),
        ];

        final res = resolver.resolve(
          searchData: search(sources: [searchSource]),
          rules: rules,
        );
        expect(res.title, 'ok');
      });
    });

    group('date only (без delay/rollout)', () {
      test('Активно начиная с baseDate (включительно)', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          rule(date: UpdateDate(baseDate), title: 'ok'),
        ];

        // До даты — не подходит
        expect(
          () => resolver.resolve(
            searchData: search(
                currentDate: baseDate.subtract(const Duration(hours: 1))),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );

        // Ровно в дату — подходит
        final res = resolver.resolve(
          searchData: search(currentDate: baseDate),
          rules: rules,
        );
        expect(res.title, 'ok');
      });

      test(
          'Dynamic date: отсутствует localReleaseDate => правило не применяется',
          () {
        final rules = [
          rule(date: UpdateDate.localReleaseDate, title: 'bad'),
        ];

        expect(
          () => resolver.resolve(searchData: search(), rules: rules),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
