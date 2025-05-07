import 'package:api_wrap/api_wrap.dart';

import 'package:dio/dio.dart';
import 'package:test/test.dart' hide Retry;

void main() {
  Never badResponse({
    int? statusCode,
    dynamic data,
  }) {
    throw DioException(
      requestOptions: RequestOptions(),
      type: DioExceptionType.badResponse,
      error: 'Failure',
      response: Response(
        requestOptions: RequestOptions(),
        statusCode: statusCode,
        data: data,
      ),
    );
  }

  group('Retry', () {
    test('maxAttempts', () async {
      Retry positiveAttemts() => Retry(maxAttempts: 1);
      Retry zeroAttemts() => Retry(maxAttempts: 0);
      Retry negativeAttemts() => Retry(maxAttempts: -1);

      expect(positiveAttemts(), isA<Retry>());
      expect(zeroAttemts, throwsA(anything));
      expect(negativeAttemts, throwsA(anything));
    });
  });

  group('ApiWrap Common Tests', () {
    late Handler<int> apiWrapper;

    setUp(() {
      apiWrapper = Handler<int>(
        parseBaseResponseError: (e) => 0,
        onError: (error) {},
      );
    });

    test('Success function call', () async {
      final r1 = await apiWrapper.apiWrap(
        () => 'Success',
        onSuccess: (res) => 'Processed $res',
      );

      expect(r1, equals('Processed Success'));
    });

    test('onError call', () async {
      final r1 = await apiWrapper.apiWrap(
        () => throw const FormatException('Err123'),
        onSuccess: (res) => 'Processed $res',
        onError: (error) {
          if (error case InternalError(error: FormatException(:final message))) {
            return 'Error handled: $message';
          }
        },
      );

      expect(r1, equals('Error handled: Err123'));
    });

    test('null onError call', () async {
      final r1 = await apiWrapper.apiWrap(
        () => throw Exception(),
        onSuccess: (res) => 'Processed $res',
      );

      expect(r1, equals(null));

      final r2 = apiWrapper.apiWrapStrict(
        () => throw Exception(),
        onSuccess: (res) => 'Processed $res',
      );

      await expectLater(r2, throwsA(isA<Exception>()));
    });

    test('ErrorResponse', () async {
      final r1 = await apiWrapper.apiWrap(
        () => badResponse(statusCode: 404),
        onError: (error) {
          if (error case ErrorResponse(:final statusCode)) {
            return 'Error handled $statusCode';
          }
        },
      );

      expect(r1, equals('Error handled 404'));
    });

    test('InternalError', () async {
      final r1 = await apiWrapper.apiWrap(
        () => throw const FormatException('InternalErrorMessage'),
        onError: (error) {
          if (error case InternalError(error: FormatException(:final message))) {
            return 'Error handled: $message';
          }
        },
      );

      expect(r1, equals('Error handled: InternalErrorMessage'));
    });

    test('Nested ErrorResponse', () async {
      final r1 = await apiWrapper.apiWrap(
        () => apiWrapper.apiWrapStrict(
          onSuccess: (res) => res,
          () => apiWrapper.apiWrapStrict(
            onSuccess: (res) => res,
            () => badResponse(statusCode: 409),
          ),
        ),
        onError: (error) {
          if (error case ErrorResponse(:final statusCode)) {
            return 'Error handled $statusCode';
          }
        },
      );

      expect(r1, equals('Error handled 409'));
    });

    test('Nested InternalError', () async {
      final r1 = await apiWrapper.apiWrap(
        () => apiWrapper.apiWrapStrict(
          onSuccess: (res) => res,
          () => apiWrapper.apiWrapStrict(
            onSuccess: (res) => res,
            () => throw const FormatException('InternalErrorMessage'),
          ),
        ),
        onError: (error) {
          if (error case InternalError(error: FormatException(:final message))) {
            return 'Error handled: $message';
          }
        },
      );

      expect(r1, equals('Error handled: InternalErrorMessage'));
    });

    test('Min execution time', () async {
      final stopwatch = Stopwatch()..start();

      Duration? onSuccessElapsed;
      final result = await apiWrapper.apiWrap(
        () => Future.delayed(Duration(milliseconds: 500), () => 'RESULT'),
        minExecutionTime: const Duration(milliseconds: 1000),
        onSuccess: (res) async {
          onSuccessElapsed = stopwatch.elapsed;
          await Future.delayed(Duration(milliseconds: 200));
          return res;
        },
      );
      stopwatch.stop();

      expect(
        onSuccessElapsed,
        greaterThanOrEqualTo(const Duration(milliseconds: 1000)),
      );
      expect(
        onSuccessElapsed,
        lessThan(const Duration(milliseconds: 1100)),
      );

      expect(result, equals('RESULT'));
      expect(
        stopwatch.elapsed,
        greaterThanOrEqualTo(const Duration(milliseconds: 1200)),
      );
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 1300)),
      );
    });

    test('Min execution time with sync function', () async {
      final stopwatch = Stopwatch()..start();

      Duration? onSuccessElapsed;
      final result = await apiWrapper.apiWrap(
        () => 'RESULT',
        minExecutionTime: const Duration(milliseconds: 1000),
        onSuccess: (res) async {
          onSuccessElapsed = stopwatch.elapsed;
          await Future.delayed(Duration(milliseconds: 200));
          return res;
        },
      );
      stopwatch.stop();

      expect(
        onSuccessElapsed,
        greaterThanOrEqualTo(const Duration(milliseconds: 1000)),
      );
      expect(
        onSuccessElapsed,
        lessThan(const Duration(milliseconds: 1100)),
      );

      expect(result, equals('RESULT'));
      expect(
        stopwatch.elapsed,
        greaterThanOrEqualTo(const Duration(milliseconds: 1200)),
      );
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 1300)),
      );
    });

    test('Min execution time Error', () async {
      final stopwatch = Stopwatch()..start();
      Duration? onErrorElapsed;
      final result = await apiWrapper.apiWrapStrict(
        () => Future.delayed(
          Duration(milliseconds: 500),
          () => throw 'TEST ERROR',
        ),
        onSuccess: (res) => '',
        minExecutionTime: const Duration(seconds: 1),
        onError: (e) async {
          onErrorElapsed = stopwatch.elapsed;

          await Future.delayed(Duration(milliseconds: 200));

          switch (e) {
            case InternalError(error: 'TEST ERROR'):
              return 'HANDLED ERROR';
            default:
              throw e;
          }
        },
      );
      stopwatch.stop();

      expect(
        onErrorElapsed,
        greaterThanOrEqualTo(const Duration(milliseconds: 1000)),
      );
      expect(
        onErrorElapsed,
        lessThan(const Duration(milliseconds: 1100)),
      );

      expect(result, equals('HANDLED ERROR'));
      expect(
        stopwatch.elapsed,
        greaterThanOrEqualTo(const Duration(milliseconds: 1200)),
      );
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 1300)),
      );
    });

    test('Delay', () async {
      final stopwatch = Stopwatch()..start();
      final result = await apiWrapper.apiWrap(
        () => 'Delayed',
        delay: const Duration(seconds: 1),
      );
      stopwatch.stop();

      expect(result, equals('Delayed'));
      expect(
        stopwatch.elapsed,
        greaterThanOrEqualTo(const Duration(seconds: 1)),
      );
    });

    test('Retry', () async {
      var attempt = 0;

      Future<String?> retryFn(Retry retry) async {
        return apiWrapper.apiWrap(
          () {
            attempt++;
            if (attempt < 3) badResponse(statusCode: 503);
            return 'Success after retries';
          },
          retry: retry,
        );
      }

      final r1 = await retryFn(
        Retry(
          maxAttempts: 3,
          retryIf: (e, s, __) {
            final error = apiWrapper.wrapError(e, s);
            if (error case ErrorResponse(statusCode: 503)) return true;
            return false;
          },
        ),
      );

      expect(r1, equals('Success after retries'));
      expect(attempt, equals(3));

      attempt = 0;
      final r2 = await retryFn(
        Retry(
          maxAttempts: 2,
          retryIf: (e, s, _) {
            final error = apiWrapper.wrapError(e, s);
            if (error case ErrorResponse(statusCode: 503)) return true;
            return false;
          },
        ),
      );

      expect(r2, equals(null));
      expect(attempt, equals(2));

      attempt = 0;
      final r3 = await retryFn(
        Retry(
          maxAttempts: 3,
          retryIf: (_, __, ___) => false,
        ),
      );

      expect(r3, equals(null));
      expect(attempt, equals(1));
    });

    test('Strict', () async {
      final r1 = await apiWrapper.apiWrapStrict(
        () => 'Success',
        onSuccess: (res) => res,
      );

      expect(r1, equals('Success'));

      final r2 = await apiWrapper.apiWrapStrict(
        () => 'Success',
        onSuccess: (res) => 'Processed $res',
      );

      expect(r2, equals('Processed Success'));

      final r3 = apiWrapper.apiWrapStrict(
        () => badResponse(statusCode: 403),
        onSuccess: (res) => 'Processed $res',
      );

      await expectLater(r3, throwsA(isA<ErrorResponse>()));

      final r4 = apiWrapper.apiWrapStrict(
        () {},
        onSuccess: (_) {
          badResponse(statusCode: 403);
        },
      );

      await expectLater(r4, throwsA(isA<ErrorResponse>()));

      final r5 = apiWrapper.apiWrapStrict(
        () {},
        onSuccess: (_) {
          badResponse(statusCode: 403);
        },
      );

      await expectLater(r5, throwsA(isA<ErrorResponse>()));
    });

    test('Throttle cancel', () async {
      const tag = 'Throttle cancel';
      final r1 = await apiWrapper.apiWrap(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Throttle(duration: const Duration(seconds: 1)),
      );

      expect(r1, equals('Success'));

      final r2 = await apiWrapper.apiWrap(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Throttle(),
      );

      expect(r2, null);

      await Future.delayed(const Duration(seconds: 1));

      final r3 = await apiWrapper.apiWrap(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Throttle(),
      );

      expect(r3, equals('Success'));
    });

    test('Throttle cancel in Strict', () async {
      const tag = 'Throttle cancel in Strict';
      final r1 = await apiWrapper.apiWrapStrict(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Throttle(duration: const Duration(seconds: 1)),
      );

      expect(r1, equals('Success'));

      final r2 = apiWrapper.apiWrapStrict(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Throttle(),
      );

      await expectLater(r2, throwsA(isA<RateLimiterError>()));

      await Future.delayed(const Duration(seconds: 1));

      final r3 = await apiWrapper.apiWrapStrict(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Throttle(),
      );

      expect(r3, equals('Success'));
    });

    test('Debounce cancel', () async {
      const tag = 'Debounce cancel';
      final r1Future = apiWrapper.apiWrap(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Debounce(duration: const Duration(seconds: 1)),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      final r2 = await apiWrapper.apiWrap(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Debounce(duration: const Duration(seconds: 1)),
      );

      final r1 = await r1Future;

      expect(r1, equals(null));
      expect(r2, equals('Success'));

      await Future.delayed(const Duration(seconds: 1));

      final r3 = await apiWrapper.apiWrap(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Debounce(duration: const Duration(seconds: 1)),
      );

      expect(r3, equals('Success'));
    });

    test('Debounce cancel in Strict', () async {
      const tag = 'Debounce cancel in Strict';

      final r1 = apiWrapper.apiWrapStrict(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Debounce(duration: const Duration(seconds: 1)),
      );

      // ignore: unawaited_futures
      expectLater(r1, throwsA(isA<RateLimiterError>()));

      await Future.delayed(const Duration(milliseconds: 200));

      final r2 = await apiWrapper.apiWrapStrict(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Debounce(duration: const Duration(milliseconds: 200)),
      );

      expect(r2, equals('Success'));

      final r3 = await apiWrapper.apiWrapStrict(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Debounce(duration: const Duration(seconds: 1)),
      );

      expect(r3, equals('Success'));

      final r4 = apiWrapper.apiWrapStrict(
        () => 'Success',
        onError: (e) => switch (e) {
          RateLimiterError(key: final tag) => tag,
          _ => throw e,
        },
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Debounce(duration: const Duration(seconds: 1)),
      );

      // ignore: unawaited_futures
      expectLater(r4, completion(equals(tag)));

      await Future.delayed(const Duration(milliseconds: 200));

      final r5 = await apiWrapper.apiWrapStrict(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Debounce(duration: const Duration(milliseconds: 200)),
      );

      expect(r5, equals('Success'));
    });

    test('Throttle cooldown', () async {
      const tag = 'Throttle cooldown';

      final cooldownList = [];

      const cooldownDuration = Duration(seconds: 1);
      final r1 = await apiWrapper.apiWrap(
        () async {
          await Future.delayed(const Duration(milliseconds: 400));
          return 'Success';
        },
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Throttle(
          duration: cooldownDuration,
          tickInterval: const Duration(milliseconds: 200),
          onCooldownStart: () => cooldownList.add('Start'),
          onCooldownEnd: () => cooldownList.add('End'),
          onCooldownTick: cooldownList.add,
        ),
      );

      expect(r1, equals('Success'));

      const delay = Duration(milliseconds: 300);
      await Future.delayed(delay);

      final r2 = await apiWrapper.apiWrap(
        () => 'Success',
        tag: tag,
        rateLimiter: Throttle(),
        onError: (error) {
          switch (error) {
            case RateLimiterError():
              return error;
            case _:
              return null;
          }
        },
      );

      expect(r2, isNotNull);
      expect(r2!.timings.duration, cooldownDuration);
      expect(r2.timings.elapsedTime, greaterThan(delay));

      await Future.delayed(const Duration(seconds: 1));

      expect(
        cooldownList,
        equals([
          'Start',
          for (int i = 0; i <= 5; i++)
            RateTimings(
              duration: cooldownDuration,
              elapsedTime: Duration(milliseconds: 200 * i),
              remainingTime: null,
            ),
          'End',
        ]),
      );

      final r3 = await apiWrapper.apiWrap(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Throttle(),
      );

      expect(r3, equals('Success'));
    });

    test('Debounce delay', () async {
      const tag = 'Debounce delay';

      final delayList = [];

      const delayDuration = Duration(seconds: 1);
      final r1Future = apiWrapper.apiWrap(
        () {},
        onSuccess: (res) => null,
        onError: (error) {
          switch (error) {
            case RateLimiterError():
              return error;
            case _:
              return null;
          }
        },
        tag: tag,
        rateLimiter: Debounce(
          duration: delayDuration,
          tickInterval: const Duration(milliseconds: 200),
          onDelayStart: () => delayList.add('Start'),
          onDelayTick: delayList.add,
          onDelayEnd: () => delayList.add('End'),
        ),
      );

      const delay = Duration(milliseconds: 300);
      await Future.delayed(delay);

      final r2 = await apiWrapper.apiWrap(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Debounce(),
      );

      expect(r2, 'Success');

      final r1 = await r1Future;

      expect(r1, isNotNull);
      expect(r1!.timings.duration, delayDuration);
      expect(r1.timings.elapsedTime, greaterThan(delay));

      await Future.delayed(const Duration(seconds: 1));

      expect(delayList.length, 5);

      expect(delayList[0], 'Start');
      expect(
        delayList[1],
        RateTimings(
          duration: delayDuration,
          elapsedTime: Duration.zero,
          remainingTime: null,
        ),
      );
      expect(
        delayList[2],
        RateTimings(
          duration: delayDuration,
          elapsedTime: Duration(milliseconds: 200),
          remainingTime: null,
        ),
      );

      final time3 = delayList[3] as RateTimings;
      expect(time3.remainingTime, Duration.zero);

      expect(time3.elapsedTime, greaterThan(delay));
      expect(time3.elapsedTime, lessThan(delay + Duration(milliseconds: 50)));
      expect(delayList[4], 'End');

      final r3 = await apiWrapper.apiWrap(
        () => 'Success',
        tag: tag,
        onSuccess: (res) => res,
        rateLimiter: Debounce(),
      );

      expect(r3, equals('Success'));
    });
  });
}
