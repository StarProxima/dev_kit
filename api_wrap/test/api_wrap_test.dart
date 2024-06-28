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

  group('ApiWrap Common Tests', () {
    late ApiWrapper<int> apiWrapper;

    setUp(() {
      apiWrapper = ApiWrapper<int>(
        options: ApiWrapController(
          parseError: (error) => 0,
        ),
        onError: (error) {},
      );
    });

    test('Success function call', () async {
      final r1 = await apiWrapper.apiWrap(
        () => 'Success',
        onSuccess: (res) => 'Processed $res',
      );

      final r2 = await apiWrapper.apiWrapSingle(
        () => 'Success',
      );

      expect(r1, equals('Processed Success'));
      expect(r2, equals('Success'));
    });

    test('onError call', () async {
      final r1 = await apiWrapper.apiWrap(
        () => throw const FormatException('Err123'),
        onSuccess: (res) => 'Processed $res',
        onError: (error) {
          if (error
              case InternalError(error: FormatException(:final message))) {
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
          if (error
              case InternalError(error: FormatException(:final message))) {
            return 'Error handled: $message';
          }
        },
      );

      expect(r1, equals('Error handled: InternalErrorMessage'));
    });

    test('Nested ErrorResponse', () async {
      final r1 = await apiWrapper.apiWrap(
        () => apiWrapper.apiWrapStrictSingle(
          () => apiWrapper.apiWrapStrictSingle(
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
        () => apiWrapper.apiWrapStrictSingle(
          () => apiWrapper.apiWrapStrictSingle(
            () => throw const FormatException('InternalErrorMessage'),
          ),
        ),
        onError: (error) {
          if (error
              case InternalError(error: FormatException(:final message))) {
            return 'Error handled: $message';
          }
        },
      );

      expect(r1, equals('Error handled: InternalErrorMessage'));
    });

    test('Min execution time', () async {
      final stopwatch = Stopwatch()..start();
      final result = await apiWrapper.apiWrap(
        () => Future.delayed(Duration(milliseconds: 500), () => 'Result'),
        minExecutionTime: const Duration(seconds: 1),
      );
      stopwatch.stop();

      expect(result, equals('Result'));
      expect(
        stopwatch.elapsed,
        greaterThanOrEqualTo(const Duration(milliseconds: 1000)),
      );
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 1100)),
      );
    });

    test('Min execution time Error', () async {
      final stopwatch = Stopwatch()..start();
      final result = await apiWrapper.apiWrapStrictSingle(
        () => Future.delayed(
          Duration(milliseconds: 500),
          () => throw 'TEST ERROR',
        ),
        minExecutionTime: const Duration(seconds: 1),
        onError: (e) {
          switch (e) {
            case InternalError(error: 'TEST ERROR'):
              return 'HANDLED ERROR';
            default:
              throw e;
          }
        },
      );
      stopwatch.stop();

      expect(result, equals('HANDLED ERROR'));
      expect(
        stopwatch.elapsed,
        greaterThanOrEqualTo(const Duration(milliseconds: 1000)),
      );
      expect(
        stopwatch.elapsed,
        lessThan(const Duration(milliseconds: 1100)),
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

      Future<String?> retryFn(Retry<int> retry) async {
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
          retryIf: (error) {
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
          retryIf: (error) {
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
          retryIf: (error) => false,
        ),
      );

      expect(r3, equals(null));
      expect(attempt, equals(1));
    });

    test('Strict', () async {
      final r1 = await apiWrapper.apiWrapStrictSingle(() => 'Success');

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
      final r1 = await apiWrapper.apiWrapSingle<String>(
        () => 'Success',
        rateLimiter: Throttle(tag: tag, duration: const Duration(seconds: 1)),
      );

      expect(r1, equals('Success'));

      final r2 = await apiWrapper.apiWrapSingle<String>(
        () => 'Success',
        rateLimiter: Throttle(tag: tag),
      );

      expect(r2, null);

      await Future.delayed(const Duration(seconds: 1));

      final r3 = await apiWrapper.apiWrapSingle<String>(
        () => 'Success',
        rateLimiter: Throttle(tag: tag),
      );

      expect(r3, equals('Success'));
    });

    test('Throttle cancel in Strict', () async {
      const tag = 'Throttle cancel in Strict';
      final r1 = await apiWrapper.apiWrapStrictSingle<String>(
        () => 'Success',
        rateLimiter: Throttle(tag: tag, duration: const Duration(seconds: 1)),
      );

      expect(r1, equals('Success'));

      final r2 = apiWrapper.apiWrapStrictSingle<String>(
        () => 'Success',
        rateLimiter: Throttle(tag: tag),
      );

      await expectLater(r2, throwsA(isA<RateCancelError>()));

      await Future.delayed(const Duration(seconds: 1));

      final r3 = await apiWrapper.apiWrapStrictSingle<String>(
        () => 'Success',
        rateLimiter: Throttle(tag: tag),
      );

      expect(r3, equals('Success'));
    });

    test('Debounce cancel', () async {
      const tag = 'Debounce cancel';
      final r1Future = apiWrapper.apiWrapSingle<String>(
        () => 'Success',
        rateLimiter: Debounce(tag: tag, duration: const Duration(seconds: 1)),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      final r2 = await apiWrapper.apiWrapSingle<String>(
        () => 'Success',
        rateLimiter: Debounce(tag: tag, duration: const Duration(seconds: 1)),
      );

      final r1 = await r1Future;

      expect(r1, equals(null));
      expect(r2, equals('Success'));

      await Future.delayed(const Duration(seconds: 1));

      final r3 = await apiWrapper.apiWrapSingle<String>(
        () => 'Success',
        rateLimiter: Debounce(tag: tag, duration: const Duration(seconds: 1)),
      );

      expect(r3, equals('Success'));
    });

    test('Debounce cancel in Strict', () async {
      const tag = 'Debounce cancel in Strict';

      final r1 = apiWrapper.apiWrapStrictSingle(
        () => 'Success',
        rateLimiter: Debounce(tag: tag, duration: const Duration(seconds: 1)),
      );

      // ignore: unawaited_futures
      expectLater(r1, throwsA(isA<RateCancelError>()));

      await Future.delayed(const Duration(milliseconds: 200));

      final r2 = await apiWrapper.apiWrapStrictSingle(
        () => 'Success',
        rateLimiter:
            Debounce(tag: tag, duration: const Duration(milliseconds: 200)),
      );

      expect(r2, equals('Success'));

      final r3 = await apiWrapper.apiWrapStrictSingle(
        () => 'Success',
        rateLimiter: Debounce(tag: tag, duration: const Duration(seconds: 1)),
      );

      expect(r3, equals('Success'));

      final r4 = apiWrapper.apiWrapStrictSingle(
        () => 'Success',
        onError: (e) => switch (e) {
          RateCancelError(:final tag) => tag,
          _ => throw e,
        },
        rateLimiter: Debounce(tag: tag, duration: const Duration(seconds: 1)),
      );

      // ignore: unawaited_futures
      expectLater(r4, completion(equals(tag)));

      await Future.delayed(const Duration(milliseconds: 200));

      final r5 = await apiWrapper.apiWrapStrictSingle(
        () => 'Success',
        rateLimiter:
            Debounce(tag: tag, duration: const Duration(milliseconds: 200)),
      );

      expect(r5, equals('Success'));
    });

    test('Throttle cooldown', () async {
      const tag = 'Throttle cooldown';

      final cooldownList = [];

      const cooldownDuration = Duration(seconds: 1);
      final r1 = await apiWrapper.apiWrapSingle(
        () async {
          await Future.delayed(const Duration(milliseconds: 400));
          return 'Success';
        },
        rateLimiter: Throttle(
          tag: tag,
          duration: cooldownDuration,
          cooldownTickInterval: const Duration(milliseconds: 200),
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
        onError: (error) {
          switch (error) {
            case RateCancelError():
              return error;
            case _:
              return null;
          }
        },
        rateLimiter: Throttle(
          tag: tag,
        ),
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
            RateTimings(cooldownDuration, Duration(milliseconds: 200 * i)),
          'End',
        ]),
      );

      final r3 = await apiWrapper.apiWrapSingle(
        () => 'Success',
        rateLimiter: Throttle(tag: tag),
      );

      expect(r3, equals('Success'));
    });

    test('Debounce delay', () async {
      const tag = 'Debounce delay';

      final delayList = [];

      const delayDuration = Duration(seconds: 1);
      final r1Future = apiWrapper.apiWrapSingle(
        () {},
        onError: (error) {
          switch (error) {
            case RateCancelError():
              return error;
            case _:
              return null;
          }
        },
        rateLimiter: Debounce(
          tag: tag,
          duration: delayDuration,
          delayTickInterval: const Duration(milliseconds: 200),
          onDelayStart: () => delayList.add('Start'),
          onDelayTick: delayList.add,
          onDelayEnd: () => delayList.add('End'),
        ),
      );

      const delay = Duration(milliseconds: 300);
      await Future.delayed(delay);

      final r2 = await apiWrapper.apiWrapSingle(
        () => 'Success',
        rateLimiter: Debounce(tag: tag),
      );

      expect(r2, 'Success');

      final r1 = await r1Future;

      expect(r1, isNotNull);
      expect(r1!.timings.duration, delayDuration);
      expect(r1.timings.elapsedTime, greaterThan(delay));

      await Future.delayed(const Duration(seconds: 1));

      expect(
        delayList,
        equals([
          'Start',
          for (int i = 0; i <= 1; i++)
            RateTimings(delayDuration, Duration(milliseconds: 200 * i)),
          'End',
        ]),
      );

      final r3 = await apiWrapper.apiWrapSingle<String>(
        () => 'Success',
        rateLimiter: Debounce(tag: tag),
      );

      expect(r3, equals('Success'));
    });
  });
}
