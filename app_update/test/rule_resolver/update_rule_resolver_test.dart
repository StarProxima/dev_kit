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
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:flutter/material.dart';

void main() {
  group('UpdateRuleResolver', () {
    const resolver = UpdateRuleResolver();

    UpdateSearchData _search({
      UpdateViewTarget target = UpdateViewTarget.card,
      UpdateLocale? locale,
      List<UpdateSource>? sources,
      String version = '1.0.0',
      AppStatus? appStatus,
      UpdateDate? date,
      DateTime? localReleaseDate,
      DateTime? updateReleaseDate,
      double segmentationPointer = 0.0,
      double rolloutPointer = 0.0,
      Map<String, dynamic>? custom,
    }) {
      return UpdateSearchData(
        platform: UpdatePlatform.android,
        sources: sources ?? const [UpdateSource.googlePlay],
        localVersion: Version.parse(version),
        displayTarget: target,
        appStatus: appStatus,
        locale: locale ?? UpdateLocale(const Locale('ru')),
        currentDate: (date ?? UpdateDate(DateTime(2024, 10, 20, 12, 0, 0))).date!,
        localReleaseDate: localReleaseDate,
        updateReleaseDate: updateReleaseDate,
        segmentationPointer: segmentationPointer,
        rolloutPointer: rolloutPointer,
        customData: custom,
      );
    }

    UpdateRuleConfig<UpdateContentData> _rule({
      List<UpdateViewTarget> targets = const [UpdateViewTarget.any],
      List<UpdateLocale> locales = const [UpdateLocale.any],
      List<UpdateSource> sources = const [UpdateSource.any],
      List<UpdateVersionConstraint> versions = const [UpdateVersionConstraint.any],
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
        _rule(
          targets: const [UpdateViewTarget.card],
          locales: [UpdateLocale(const Locale('ru'))],
          sources: const [UpdateSource.googlePlay],
          versions: [UpdateVersionConstraint(VersionConstraint.parse('>=1.0.0 <2.0.0'))],
          title: 'A',
        ),
      ];

      final res = resolver.resolve(
        searchData: _search(),
        rules: rules,
      );

      expect(res.title, 'A');
    });

    test('Приоритет последнего правила (мердж)', () {
      final rules = [
        _rule(title: 'A', description: 'd1'),
        _rule(title: 'B'),
      ];

      final res = resolver.resolve(
        searchData: _search(),
        rules: rules,
      );

      expect(res.title, 'B');
      expect(res.description, 'd1');
    });

    test('Сегментация: пропускает при pointer > threshold', () {
      final rules = [
        _rule(segmentation: 10, title: 'A'), // порог 0.1
      ];

      // pointer 0.2 > 0.1 => правило не подходит
      expect(
        () => resolver.resolve(searchData: _search(segmentationPointer: 0.2), rules: rules),
        throwsA(isA<Exception>()),
      );
    });

    test('Delay: применяется только после delay', () {
      final baseDate = DateTime(2024, 10, 20, 12, 0, 0);
      final rules = [
        _rule(date: UpdateDate(baseDate), delay: const Duration(hours: 24), title: 'A'),
      ];

      // now до (base+24h) — правило не подходит
      expect(
        () => resolver.resolve(
          searchData: _search(date: UpdateDate(baseDate.add(const Duration(hours: 23)))),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );

      // now после (base+24h)
      final res = resolver.resolve(
        searchData: _search(date: UpdateDate(baseDate.add(const Duration(hours: 25)))),
        rules: rules,
      );
      expect(res.title, 'A');
    });

    test('Rollout: pointer должен быть <= прогрессу выката', () {
      final baseDate = DateTime(2024, 10, 20, 12, 0, 0);
      final rules = [
        _rule(date: UpdateDate(baseDate), rollout: const Duration(hours: 100), title: 'A'),
      ];

      // Через 10 часов, прогресс ~0.1 — pointer 0.2 не проходит
      expect(
        () => resolver.resolve(
          searchData: _search(
            date: UpdateDate(baseDate.add(const Duration(hours: 10))),
            rolloutPointer: 0.2,
          ),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );

      // pointer 0.05 проходит
      final res = resolver.resolve(
        searchData: _search(
          date: UpdateDate(baseDate.add(const Duration(hours: 10))),
          rolloutPointer: 0.05,
        ),
        rules: rules,
      );
      expect(res.title, 'A');
    });

    test('Платформы и customData + dynamic dates (local/update release)', () {
      final baseDate = DateTime(2024, 10, 20, 12, 0, 0);

      final rules = [
        // 1. База, работает везде, задаём заглушки
        _rule(title: 'base', description: 'd0', custom: const {'env': 'prod'}),

        // 2. Источник googlePlay + платформа android => мердж описания
        _rule(
          sources: const [UpdateSource.googlePlay],
          targets: const [UpdateViewTarget.card],
          versions: [UpdateVersionConstraint(VersionConstraint.parse('>=1.0.0'))],
          description: 'android-store',
        ),

        // 3. Сегментация 100% + rollout 48h, pointer 0.5 через 24h — не пройдёт
        _rule(
          date: UpdateDate.updateReleaseDate,
          rollout: const Duration(hours: 48),
          segmentation: 100,
          title: 'segmented',
        ),

        // 4. Delay от localReleaseDate: через 20h не пройдёт, через 30h — пройдёт
        _rule(
          date: UpdateDate.localReleaseDate,
          delay: const Duration(hours: 24),
          title: 'after-delay',
        ),
      ];

      // Первый проход — 20h после updateRelease, rolloutPointer 0.6,
      // target=screen (чтобы правило 2 не прошло), custom=null (чтобы правило 1 не прошло)
      expect(
        () => resolver.resolve(
          searchData: _search(
            target: UpdateViewTarget.screen,
            date: UpdateDate(baseDate.add(const Duration(hours: 20))),
            rolloutPointer: 0.6,
            localReleaseDate: baseDate,
            updateReleaseDate: baseDate,
            sources: const [UpdateSource.googlePlay],
            // customData отсутствует => правило 1 не пройдёт
            custom: null,
          ),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );

      // Второй проход — 30h после localReleaseDate -> сработает правило 4 (delay 24h)
      final res2 = resolver.resolve(
        searchData: _search(
          date: UpdateDate(baseDate.add(const Duration(hours: 30))),
          rolloutPointer: 0.5,
          localReleaseDate: baseDate,
          updateReleaseDate: baseDate,
          sources: const [UpdateSource.googlePlay],
          // теперь передаём customData для базового правила
          custom: const {'env': 'prod'},
        ),
        rules: rules,
      );
      expect(res2.title, 'after-delay');
      expect(res2.description, 'android-store');
    });
  });
}
