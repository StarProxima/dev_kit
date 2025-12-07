import 'package:app_update/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/resolver_test_helpers.dart';

void main() {
  group('UpdateRuleResolver - Temporal matching (comprehensive)', () {
    const resolver = UpdateRuleResolver();

    group('UpdateDate.any', () {
      test('UpdateDate.any всегда активно', () {
        final rules = [
          createTestRule(title: 'any_date'),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: DateTime(2024),
            // Остальные даты null
          ),
          rules: rules,
        );
        expect(res.title, 'any_date');
      });
    });

    group('Конкретные даты', () {
      test('До даты — правило не подходит', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(date: UpdateDate(baseDate), title: 'after_date'),
        ];

        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              currentDate: baseDate.subtract(const Duration(hours: 1)),
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('Ровно в дату — правило подходит', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(date: UpdateDate(baseDate), title: 'exact_date'),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(currentDate: baseDate),
          rules: rules,
        );
        expect(res.title, 'exact_date');
      });

      test('После даты — правило подходит', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(date: UpdateDate(baseDate), title: 'after_date'),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 5)),
          ),
          rules: rules,
        );
        expect(res.title, 'after_date');
      });

      test('Граничный случай: на миллисекунду раньше', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(date: UpdateDate(baseDate), title: 'should_fail'),
        ];

        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              currentDate: baseDate.subtract(const Duration(milliseconds: 1)),
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('Граничный случай: на миллисекунду позже', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(date: UpdateDate(baseDate), title: 'should_pass'),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(milliseconds: 1)),
          ),
          rules: rules,
        );
        expect(res.title, 'should_pass');
      });
    });

    group('Динамические даты', () {
      test('localReleaseDate: отсутствует => правило не подходит', () {
        final rules = [
          createTestRule(date: UpdateDate.localReleaseDate, title: 'bad'),
        ];

        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test(
        'localReleaseDate: присутствует и currentDate после => подходит',
        () {
          final localRelease = DateTime(2024, 1, 1, 10);
          final current = DateTime(2024, 1, 1, 12);
          final rules = [
            createTestRule(date: UpdateDate.localReleaseDate, title: 'local'),
          ];

          final res = resolver.resolve(
            searchData: createTestSearchData(
              currentDate: current,
              localReleaseDate: localRelease,
            ),
            rules: rules,
          );
          expect(res.title, 'local');
        },
      );

      test('updateReleaseDate: присутствует => подходит', () {
        final updateRelease = DateTime(2024, 1, 5);
        final current = DateTime(2024, 1, 10);
        final rules = [
          createTestRule(date: UpdateDate.updateReleaseDate, title: 'update'),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: current,
            updateReleaseDate: updateRelease,
          ),
          rules: rules,
        );
        expect(res.title, 'update');
      });

      test('appUpdateDate: присутствует => подходит', () {
        final appUpdate = DateTime(2024, 2);
        final current = DateTime(2024, 2, 5);
        final rules = [
          createTestRule(date: UpdateDate.appUpdateDate, title: 'app_update'),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: current,
            appUpdateDate: appUpdate,
          ),
          rules: rules,
        );
        expect(res.title, 'app_update');
      });

      test('appInstallDate: присутствует => подходит', () {
        final appInstall = DateTime(2023, 12, 15);
        final current = DateTime(2024, 1, 15);
        final rules = [
          createTestRule(date: UpdateDate.appInstallDate, title: 'app_install'),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: current,
            appInstallDate: appInstall,
          ),
          rules: rules,
        );
        expect(res.title, 'app_install');
      });

      test('Все динамические даты null => правила не подходят', () {
        final rules = [
          createTestRule(date: UpdateDate.localReleaseDate, title: 'local'),
          createTestRule(date: UpdateDate.updateReleaseDate, title: 'update'),
          createTestRule(date: UpdateDate.appUpdateDate, title: 'app_update'),
          createTestRule(date: UpdateDate.appInstallDate, title: 'app_install'),
        ];

        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Delay (задержка)', () {
      test('Delay от конкретной даты: до delay => не подходит', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            delay: const Duration(hours: 24),
            title: 'with_delay',
          ),
        ];

        // Через 12 часов после base (до delay) — не подходит
        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              currentDate: baseDate.add(const Duration(hours: 12)),
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('Delay от конкретной даты: после delay => подходит', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            delay: const Duration(hours: 24),
            title: 'with_delay',
          ),
        ];

        // Через 30 часов после base (после delay) — подходит
        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 30)),
          ),
          rules: rules,
        );
        expect(res.title, 'with_delay');
      });

      test('Delay от динамической даты', () {
        final localRelease = DateTime(2024, 1, 1, 10);
        final current = DateTime(2024, 1, 2, 15); // +29 часов
        final rules = [
          createTestRule(
            date: UpdateDate.localReleaseDate,
            delay: const Duration(hours: 24),
            title: 'dynamic_delay',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: current,
            localReleaseDate: localRelease,
          ),
          rules: rules,
        );
        expect(res.title, 'dynamic_delay');
      });

      test('Граничный случай delay: ровно на границе', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            delay: const Duration(hours: 24),
            title: 'exact_delay',
          ),
        ];

        // Ровно через 24 часа — должно подходить (включительно)
        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 24)),
          ),
          rules: rules,
        );
        expect(res.title, 'exact_delay');
      });
    });

    group('Rollout (прогрессивный выкат)', () {
      test('Rollout: начало выката (pointer низкий)', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            rollout: const Duration(hours: 100),
            title: 'rollout_start',
          ),
        ];

        // Через 10 часов: прогресс ~0.1, pointer 0.05 — подходит
        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 10)),
            rolloutPointer: 0.05,
          ),
          rules: rules,
        );
        expect(res.title, 'rollout_start');
      });

      test('Rollout: начало выката (pointer высокий)', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            rollout: const Duration(hours: 100),
            title: 'rollout_fail',
          ),
        ];

        // Через 10 часов: прогресс ~0.1, pointer 0.2 — не подходит
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
      });

      test('Rollout: середина выката', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            rollout: const Duration(hours: 100),
            title: 'rollout_middle',
          ),
        ];

        // Через 50 часов: прогресс ~0.5, pointer 0.3 — подходит
        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 50)),
            rolloutPointer: 0.3,
          ),
          rules: rules,
        );
        expect(res.title, 'rollout_middle');
      });

      test('Rollout: конец выката (100%)', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            rollout: const Duration(hours: 100),
            title: 'rollout_complete',
          ),
        ];

        // Через 150 часов: прогресс 1.0 (clamped), pointer 0.9 — подходит
        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 150)),
            rolloutPointer: 0.9,
          ),
          rules: rules,
        );
        expect(res.title, 'rollout_complete');
      });

      test('Rollout: pointer точно на границе', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            rollout: const Duration(hours: 100),
            title: 'rollout_exact',
          ),
        ];

        // Через 25 часов: прогресс 0.25, pointer 0.25 — должно подходить
        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 25)),
            rolloutPointer: 0.25,
          ),
          rules: rules,
        );
        expect(res.title, 'rollout_exact');
      });

      test('Rollout граничный случай: pointer чуть больше прогресса', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            rollout: const Duration(hours: 100),
            title: 'rollout_over',
          ),
        ];

        // Через 25 часов: прогресс 0.25, pointer 0.26 — не подходит
        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              currentDate: baseDate.add(const Duration(hours: 25)),
              rolloutPointer: 0.26,
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Segmentation (A/B тестирование)', () {
      test('Segmentation 50%: pointer в первой половине', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            segmentation: 50,
            title: 'segment_in',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 1)),
            userSegmentationPointer: 0.3, // 30% < 50%
          ),
          rules: rules,
        );
        expect(res.title, 'segment_in');
      });

      test('Segmentation 50%: pointer во второй половине', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            segmentation: 50,
            title: 'segment_out',
          ),
        ];

        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              currentDate: baseDate.add(const Duration(hours: 1)),
              userSegmentationPointer: 0.7, // 70% > 50%
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('Segmentation 100%: всегда подходит', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            segmentation: 100,
            title: 'segment_all',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 1)),
            userSegmentationPointer: 0.99,
          ),
          rules: rules,
        );
        expect(res.title, 'segment_all');
      });

      test('Segmentation 0%: только pointer 0.0 подходит', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            segmentation: 0,
            title: 'segment_zero_exact',
          ),
        ];

        // pointer = 0.0 проходит (равно threshold)
        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 1)),
          ),
          rules: rules,
        );
        expect(res.title, 'segment_zero_exact');

        // pointer > 0.0 не проходит
        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              currentDate: baseDate.add(const Duration(hours: 1)),
              userSegmentationPointer: 0.01,
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('Segmentation: граничный случай точно на границе', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            segmentation: 30,
            title: 'segment_exact',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 1)),
            userSegmentationPointer: 0.3, // Ровно на границе 30%
          ),
          rules: rules,
        );
        expect(res.title, 'segment_exact');
      });
    });

    group('Комплексные сценарии', () {
      test('Delay + Rollout + Segmentation: все условия соблюдены', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            delay: const Duration(hours: 24), // Задержка 24ч
            rollout: const Duration(hours: 48), // Выкат 48ч
            segmentation: 60, // 60% пользователей
            title: 'complex_success',
          ),
        ];

        // Через 30 часов после base (6 часов после delay):
        // rollout прогресс = 6/48 = 0.125
        // segmentation: 40% < 60%
        // rollout: 0.1 < 0.125
        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 30)),
            userSegmentationPointer: 0.4, // 40%
            rolloutPointer: 0.1, // 10%
          ),
          rules: rules,
        );
        expect(res.title, 'complex_success');
      });

      test('Delay + Rollout + Segmentation: segmentation не проходит', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            delay: const Duration(hours: 24),
            rollout: const Duration(hours: 48),
            segmentation: 30, // 30% пользователей
            title: 'complex_fail_segment',
          ),
        ];

        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              currentDate: baseDate.add(const Duration(hours: 30)),
              userSegmentationPointer: 0.5, // 50% > 30%
              rolloutPointer: 0.1,
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('Delay + Rollout + Segmentation: rollout не проходит', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            delay: const Duration(hours: 24),
            rollout: const Duration(hours: 48),
            segmentation: 80,
            title: 'complex_fail_rollout',
          ),
        ];

        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              currentDate: baseDate.add(const Duration(hours: 30)),
              userSegmentationPointer: 0.5, // 50% < 80% ✓
              rolloutPointer: 0.2, // 20% > 12.5% ✗
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('Динамическая дата + Delay + Rollout', () {
        final localRelease = DateTime(2024, 1, 1, 10);
        final current = DateTime(2024, 1, 3, 14); // +52 часа от localRelease
        final rules = [
          createTestRule(
            date: UpdateDate.localReleaseDate,
            delay: const Duration(hours: 24), // Активно с +24ч
            rollout: const Duration(hours: 72), // Выкат 72ч
            title: 'dynamic_complex',
          ),
        ];

        // 52 часа от localRelease - 24ч delay = 28 часов с начала rollout
        // Прогресс rollout = 28/72 ≈ 0.39
        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: current,
            localReleaseDate: localRelease,
            rolloutPointer: 0.3, // 30% < 39% ✓
          ),
          rules: rules,
        );
        expect(res.title, 'dynamic_complex');
      });

      test('Реалистичный сценарий выката обновления', () {
        final updateRelease = DateTime(2024, 1, 1, 9); // 09:00
        final currentTime = DateTime(2024, 1, 4, 15, 30); // +3d 6.5h

        final rules = [
          createTestRule(
            date: UpdateDate.updateReleaseDate,
            delay:
                const Duration(hours: 12), // Задержка на 12ч для стабилизации
            rollout: const Duration(days: 7), // Выкат на неделю
            segmentation: 25, // Только 25% пользователей
            title: 'production_rollout',
          ),
        ];

        // Время с начала rollout = (3d 6.5h) - 12h = ~66.5h
        // Прогресс rollout = 66.5 / 168 ≈ 0.396 (39.6%)
        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: currentTime,
            updateReleaseDate: updateRelease,
            userSegmentationPointer: 0.15, // 15% < 25% ✓
            rolloutPointer: 0.35, // 35% < 39.6% ✓
          ),
          rules: rules,
        );
        expect(res.title, 'production_rollout');
      });
    });

    group('Граничные случаи и edge cases', () {
      test('userSegmentationPointer = 0.0', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            segmentation: 10, // 10%
            title: 'edge_segment_zero',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 1)),
          ),
          rules: rules,
        );
        expect(res.title, 'edge_segment_zero');
      });

      test('rolloutPointer = 0.0', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            rollout: const Duration(hours: 24),
            title: 'edge_rollout_zero',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 1)),
          ),
          rules: rules,
        );
        expect(res.title, 'edge_rollout_zero');
      });

      test('rolloutPointer = 1.0 на полностью завершенном rollout', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            rollout: const Duration(hours: 24),
            title: 'edge_rollout_complete',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate:
                baseDate.add(const Duration(hours: 50)), // Много времени прошло
            rolloutPointer: 1, // 100%
          ),
          rules: rules,
        );
        expect(res.title, 'edge_rollout_complete');
      });

      test('Очень большие значения segmentation (>100) обрезаются', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            segmentation: 150, // >100% — должно стать 100%
            title: 'edge_segment_clamp',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 1)),
            userSegmentationPointer: 0.99, // 99% < 100% ✓
          ),
          rules: rules,
        );
        expect(res.title, 'edge_segment_clamp');
      });

      test('Отрицательная segmentation обрезается до 0', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            segmentation: -10, // Отрицательное — должно стать 0%
            title: 'edge_segment_negative',
          ),
        ];

        // С segmentation 0% пускает только pointer = 0.0
        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate.add(const Duration(hours: 1)),
          ),
          rules: rules,
        );
        expect(res.title, 'edge_segment_negative');

        // pointer > 0.0 не проходит
        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              currentDate: baseDate.add(const Duration(hours: 1)),
              userSegmentationPointer: 0.01,
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('currentDate до baseDate с delay — не подходит', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            delay: const Duration(hours: 1),
            title: 'before_delay',
          ),
        ];

        expect(
          () => resolver.resolve(
            searchData: createTestSearchData(
              currentDate: baseDate, // Ровно на base, но до delay
            ),
            rules: rules,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('Нулевой rollout (Duration.zero)', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            rollout: Duration.zero,
            title: 'zero_rollout',
          ),
        ];

        // С нулевым rollout только pointer=0 проходит
        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate,
          ),
          rules: rules,
        );
        expect(res.title, 'zero_rollout');
      });

      test('Нулевая задержка (Duration.zero)', () {
        final baseDate = DateTime(2024, 1, 1, 12);
        final rules = [
          createTestRule(
            date: UpdateDate(baseDate),
            delay: Duration.zero,
            title: 'zero_delay',
          ),
        ];

        final res = resolver.resolve(
          searchData: createTestSearchData(
            currentDate: baseDate, // Сразу с базовой даты
          ),
          rules: rules,
        );
        expect(res.title, 'zero_delay');
      });
    });
  });
}
