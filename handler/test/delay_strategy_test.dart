import 'package:handler/handler.dart';
import 'package:test/test.dart';

void main() {
  group('DelayStrategy', () {
    final options = RetryOptions(
      maxAttempts: 5,
      delayFactor: const Duration(milliseconds: 100),
      minDelay: const Duration(milliseconds: 50),
      maxDelay: const Duration(milliseconds: 1000),
      randomizationFactor:
          0.0, // Отключаем рандомизацию для детерминированных тестов
    );

    RetryStats createStats(int attempt) {
      return RetryStats(
        key: 'test',
        options: options,
        currentAttempt: attempt,
        failedAttempts: attempt - 1,
        delayBeforePreviosAttempt: Duration.zero,
        delayBeforeNextAttempt: Duration.zero,
        startTime: DateTime.now(),
        elapsedTotalTime: Duration.zero,
        willRetry: true,
        isRetryCanceled: false,
      );
    }

    test('linear strategy increases delay linearly', () {
      final stats1 = createStats(1);
      final stats2 = createStats(2);
      final stats3 = createStats(3);

      final delay1 = DelayStrategy.linear.calculateDelay(stats1);
      final delay2 = DelayStrategy.linear.calculateDelay(stats2);
      final delay3 = DelayStrategy.linear.calculateDelay(stats3);

      // Без рандомизации задержка должна быть равна minDelay + delayFactor * attempt
      expect(
          delay1.inMilliseconds,
          options.minDelay.inMilliseconds +
              options.delayFactor.inMilliseconds * 1);
      expect(
          delay2.inMilliseconds,
          options.minDelay.inMilliseconds +
              options.delayFactor.inMilliseconds * 2);
      expect(
          delay3.inMilliseconds,
          options.minDelay.inMilliseconds +
              options.delayFactor.inMilliseconds * 3);

      // Проверка, что задержка линейно увеличивается
      final diff12 = delay2.inMilliseconds - delay1.inMilliseconds;
      final diff23 = delay3.inMilliseconds - delay2.inMilliseconds;
      expect(diff12, diff23);
    });

    test('exponential strategy increases delay exponentially', () {
      final stats1 = createStats(1);
      final stats2 = createStats(2);
      final stats3 = createStats(3);

      final delay1 = DelayStrategy.exponential.calculateDelay(stats1);
      final delay2 = DelayStrategy.exponential.calculateDelay(stats2);
      final delay3 = DelayStrategy.exponential.calculateDelay(stats3);

      // Без рандомизации задержка должна быть равна minDelay + delayFactor * 2^attempt
      expect(
          delay1.inMilliseconds,
          options.minDelay.inMilliseconds +
              options.delayFactor.inMilliseconds * 2);
      expect(
          delay2.inMilliseconds,
          options.minDelay.inMilliseconds +
              options.delayFactor.inMilliseconds * 4);
      expect(
          delay3.inMilliseconds,
          options.minDelay.inMilliseconds +
              options.delayFactor.inMilliseconds * 8);
    });

    test('fixed strategy returns constant delay regardless of attempt', () {
      final stats1 = createStats(1);
      final stats2 = createStats(2);
      final stats3 = createStats(3);

      final delay1 = DelayStrategy.fixed.calculateDelay(stats1);
      final delay2 = DelayStrategy.fixed.calculateDelay(stats2);
      final delay3 = DelayStrategy.fixed.calculateDelay(stats3);

      // Без рандомизации задержка должна быть равна delayFactor
      expect(delay1.inMilliseconds, options.delayFactor.inMilliseconds);
      expect(delay2.inMilliseconds, options.delayFactor.inMilliseconds);
      expect(delay3.inMilliseconds, options.delayFactor.inMilliseconds);

      // Все задержки должны быть равны
      expect(delay1, delay2);
      expect(delay2, delay3);
    });

    test('zero strategy always returns zero duration', () {
      final stats1 = createStats(1);
      final stats2 = createStats(2);
      final stats3 = createStats(3);

      final delay1 = DelayStrategy.zero.calculateDelay(stats1);
      final delay2 = DelayStrategy.zero.calculateDelay(stats2);
      final delay3 = DelayStrategy.zero.calculateDelay(stats3);

      expect(delay1, Duration.zero);
      expect(delay2, Duration.zero);
      expect(delay3, Duration.zero);
    });

    test('sqrt strategy increases delay using square root function', () {
      final stats1 = createStats(1);
      final stats2 = createStats(4);
      final stats3 = createStats(9);

      final delay1 = DelayStrategy.sqrt.calculateDelay(stats1);
      final delay2 = DelayStrategy.sqrt.calculateDelay(stats2);
      final delay3 = DelayStrategy.sqrt.calculateDelay(stats3);

      // Без рандомизации задержка должна быть равна minDelay + delayFactor * sqrt(attempt)
      expect(
          delay1.inMilliseconds,
          options.minDelay.inMilliseconds +
              options.delayFactor.inMilliseconds * 1);
      expect(
          delay2.inMilliseconds,
          options.minDelay.inMilliseconds +
              options.delayFactor.inMilliseconds * 2);
      expect(
          delay3.inMilliseconds,
          options.minDelay.inMilliseconds +
              options.delayFactor.inMilliseconds * 3);
    });

    test('byDelays uses predefined delays', () {
      final delayList = [
        const Duration(milliseconds: 100),
        const Duration(milliseconds: 200),
        const Duration(milliseconds: 400),
      ];
      final strategy = DelayStrategy.byDelays(delayList);

      final stats1 = createStats(1);
      final stats2 = createStats(2);
      final stats3 = createStats(3);
      final stats4 = createStats(4); // Выходит за пределы списка

      expect(strategy.calculateDelay(stats1), delayList[0]);
      expect(strategy.calculateDelay(stats2), delayList[1]);
      expect(strategy.calculateDelay(stats3), delayList[2]);
      expect(strategy.calculateDelay(stats4),
          delayList.last); // Должен использоваться последний элемент
    });

    test('custom delayList strategy can implement custom patterns', () {
      // Создаем кастомную стратегию через список задержек
      final customDelays = [
        const Duration(milliseconds: 50),
        const Duration(milliseconds: 100),
        const Duration(milliseconds: 150),
        const Duration(milliseconds: 200),
      ];

      final customStrategy = DelayStrategy.byDelays(customDelays);

      final stats1 = createStats(1);
      final stats2 = createStats(2);
      final stats3 = createStats(3);
      final stats4 = createStats(4);
      final stats5 = createStats(5); // Выходит за пределы списка

      expect(customStrategy.calculateDelay(stats1), customDelays[0]);
      expect(customStrategy.calculateDelay(stats2), customDelays[1]);
      expect(customStrategy.calculateDelay(stats3), customDelays[2]);
      expect(customStrategy.calculateDelay(stats4), customDelays[3]);
      expect(customStrategy.calculateDelay(stats5),
          customDelays.last); // Используется последний элемент
    });

    test('custom strategy uses provided function', () {
      // Кастомная функция расчета задержки: умножаем номер попытки на 75 мс
      final customStrategy = DelayStrategy.custom((stats) {
        return Duration(milliseconds: stats.currentAttempt * 75);
      });

      final stats1 = createStats(1);
      final stats2 = createStats(2);
      final stats3 = createStats(3);

      expect(customStrategy.calculateDelay(stats1), Duration(milliseconds: 75));
      expect(
          customStrategy.calculateDelay(stats2), Duration(milliseconds: 150));
      expect(
          customStrategy.calculateDelay(stats3), Duration(milliseconds: 225));

      // Проверка, что задержка линейно увеличивается
      final diff12 = customStrategy.calculateDelay(stats2).inMilliseconds -
          customStrategy.calculateDelay(stats1).inMilliseconds;
      final diff23 = customStrategy.calculateDelay(stats3).inMilliseconds -
          customStrategy.calculateDelay(stats2).inMilliseconds;
      expect(diff12, diff23);
    });

    test('max delay is respected', () {
      // Создаем опции с низким maxDelay
      final optionsWithLowMax = RetryOptions(
        maxAttempts: 5,
        delayFactor: const Duration(milliseconds: 100),
        minDelay: const Duration(milliseconds: 50),
        maxDelay: const Duration(milliseconds: 250), // Низкий максимум
        randomizationFactor: 0.0,
      );

      RetryStats createStatsWithLowMax(int attempt) {
        return RetryStats(
          key: 'test',
          options: optionsWithLowMax,
          currentAttempt: attempt,
          failedAttempts: attempt - 1,
          delayBeforePreviosAttempt: Duration.zero,
          delayBeforeNextAttempt: Duration.zero,
          startTime: DateTime.now(),
          elapsedTotalTime: Duration.zero,
          willRetry: true,
          isRetryCanceled: false,
        );
      }

      // Проверка линейной стратегии
      final linearStats =
          createStatsWithLowMax(5); // 50 + 100*5 = 550 мс (больше максимума)
      expect(
          DelayStrategy.linear.calculateDelay(linearStats).inMilliseconds, 250);

      // Проверка экспоненциальной стратегии
      final expStats =
          createStatsWithLowMax(3); // 50 + 100*8 = 850 мс (больше максимума)
      expect(DelayStrategy.exponential.calculateDelay(expStats).inMilliseconds,
          250);

      // Проверка стратегии с корнем
      final sqrtStats = createStatsWithLowMax(
          10); // 50 + 100*sqrt(10) ≈ 366 мс (больше максимума)
      expect(DelayStrategy.sqrt.calculateDelay(sqrtStats).inMilliseconds, 250);
    });
  });
}
