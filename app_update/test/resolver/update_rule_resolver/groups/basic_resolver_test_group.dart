part of '../update_rule_resolver_test.dart';

void runBasicResolverTests() {
  group('UpdateRuleResolver - Basic functionality', () {
    const resolver = UpdateRuleResolver();

    test('Простое совпадение по таргету/локали/источнику/версии', () {
      final rules = [
        createTestRule(
          targets: const [UpdateViewTarget.card],
          locales: [const UpdateLocale(Locale('ru'))],
          sources: const [UpdateSource.googlePlay],
          versions: [
            UpdateVersionConstraint(VersionConstraint.parse('>=1.0.0 <2.0.0'))
          ],
          title: 'A',
        ),
      ];

      final res =
          resolver.resolve(searchData: createTestSearchData(), rules: rules);

      expect(res.title, 'A');
    });

    test('Приоритет последнего правила (мердж)', () {
      final rules = [
        createTestRule(title: 'A', description: 'd1'),
        createTestRule(title: 'B'),
      ];

      final res =
          resolver.resolve(searchData: createTestSearchData(), rules: rules);

      expect(res.title, 'B');
      expect(res.description, 'd1');
    });

    test('Сегментация: пропускает при pointer > threshold', () {
      final rules = [
        createTestRule(segmentation: 10, title: 'A'), // порог 0.1
      ];

      // pointer 0.2 > 0.1 => правило не подходит
      expect(
        () => resolver.resolve(
            searchData: createTestSearchData(segmentationPointer: 0.2),
            rules: rules),
        throwsA(isA<Exception>()),
      );
    });

    test('Delay: применяется только после delay', () {
      final baseDate = DateTime(2024, 10, 20, 12);
      final rules = [
        createTestRule(
            date: UpdateDate(baseDate),
            delay: const Duration(hours: 24),
            title: 'A'),
      ];

      // now до (base+24h) — правило не подходит
      expect(
        () => resolver.resolve(
          searchData: createTestSearchData(
              currentDate: baseDate.add(const Duration(hours: 23))),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );

      // now после (base+24h)
      final res = resolver.resolve(
        searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 25))),
        rules: rules,
      );
      expect(res.title, 'A');
    });

    test('Rollout: pointer должен быть <= прогрессу выката', () {
      final baseDate = DateTime(2024, 10, 20, 12);
      final rules = [
        createTestRule(
            date: UpdateDate(baseDate),
            rollout: const Duration(hours: 100),
            title: 'A'),
      ];

      // Через 10 часов, прогресс ~0.1 — pointer 0.2 не проходит
      expect(
        () => resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 10)),
            rolloutPointer: 0.2,
          ),
          rules: rules,
        ),
        throwsA(isA<Exception>()),
      );

      // pointer 0.05 проходит
      final res = resolver.resolve(
        searchData: createTestSearchData(
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
        createTestRule(
            title: 'base', description: 'd0', custom: const {'env_is': 'prod'}),

        // 2. Источник googlePlay + платформа android => мердж описания
        createTestRule(
          sources: const [UpdateSource.googlePlay],
          targets: const [UpdateViewTarget.card],
          versions: [
            UpdateVersionConstraint(VersionConstraint.parse('>=1.0.0'))
          ],
          description: 'android-store',
        ),

        // 3. Сегментация 100% + rollout 48h, pointer 0.5 через 24h — не пройдёт
        createTestRule(
          date: UpdateDate.updateReleaseDate,
          rollout: const Duration(hours: 48),
          segmentation: 100,
          title: 'segmented',
        ),

        // 4. Delay от localReleaseDate: через 20h не пройдёт, через 30h — пройдёт
        createTestRule(
          date: UpdateDate.localReleaseDate,
          delay: const Duration(hours: 24),
          title: 'after-delay',
        ),
      ];

      // Первый проход — 20h после updateRelease, rolloutPointer 0.6,
      // target=screen (чтобы правило 2 не прошло), custom=null (чтобы правило 1 не прошло)
      expect(
        () => resolver.resolve(
          searchData: createTestSearchData(
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
        searchData: createTestSearchData(
          currentDate: baseDate.add(const Duration(hours: 30)),
          rolloutPointer: 0.5,
          localReleaseDate: baseDate,
          updateReleaseDate: baseDate,
          sources: const [UpdateSource.googlePlay],
          // теперь передаём customData для базового правила
          custom: const {
            'env': 'PROD',
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
  });
}
