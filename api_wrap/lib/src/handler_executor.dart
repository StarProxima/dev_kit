import 'dart:async';

import 'package:meta/meta.dart';

import 'handled_error.dart';
import 'rate_limiter/rate_limiter.dart';
import 'rate_limiter/rate_operation.dart';
import 'retry/retry.dart';

/// Тип колбека, используемый для обработки ошибок API.
typedef OnError<BaseResponseError, Result> = FutureOr<Result> Function(HandledError<BaseResponseError> e);

typedef WrapError<BaseResponseError> = HandledError<BaseResponseError> Function(Object e, StackTrace s);

/// Оболочка API для внутреннего использования, управляет повторными попытками,
/// ограничением частоты операций и обработкой ошибок.
@internal
class HandlerExecutor<BaseResponseError> {
  HandlerExecutor();

  @internal
  FutureOr<D?> execute<T, D>({
    required FutureOr<T> Function() function,
    required Object? key,
    required Duration? delay,
    required Duration? minExecutionTime,
    required Retry? retry,
    required RateLimiter? rateLimiter,
    required FutureOr<D?> Function(T)? onSuccess,
    required OnError<BaseResponseError, D?>? onError,
    required RateOperationsContainer container,
    required WrapError<BaseResponseError> wrapError,
  }) async {
    final fn = _wrapWithRateLimiter(
      container: container,
      rateLimiter: rateLimiter,
      tag: key,
      onError: onError,
      function: () => _wrapWithCallbacks(
        wrapError: wrapError,
        onSuccess: onSuccess,
        onError: onError,
        function: () => _wrapWithDelays(
          delay: delay,
          minExecutionTime: minExecutionTime,
          function: () => _wrapWithRetry(
            retry: retry,
            function: function,
          ),
        ),
      ),
    );

    return fn;
  }

  // Функция-обертка для выполнения запроса и обработки ответа
  FutureOr<D?> _wrapWithCallbacks<T, D>({
    required WrapError<BaseResponseError> wrapError,
    required FutureOr<D?> Function(T)? onSuccess,
    required OnError<BaseResponseError, D?>? onError,
    required FutureOr<T> Function() function,
  }) async {
    try {
      final futureOr = function();
      final T response = switch (futureOr) {
        Future() => await futureOr,
        _ => futureOr,
      };

      final onSuccessFutureOr = onSuccess?.call(response);

      final D? onSuccessResponse = switch (onSuccessFutureOr) {
        Future() => await onSuccessFutureOr,
        _ => onSuccessFutureOr,
      };

      final result = onSuccessResponse ?? (response is D ? response as D : null);

      return result;
    } catch (e, s) {
      final err = wrapError(e, s);

      // Не эвейтим, т.к. не хотим для onError ловить исключения,
      // они поймаются при следующем эвейте
      final errorResult = onError?.call(err);

      return errorResult;
    }
  }

  FutureOr<T> _wrapWithDelays<T>({
    required Duration? delay,
    required Duration? minExecutionTime,
    required FutureOr<T> Function() function,
  }) async {
    // Обрабатываем начальную задержку запроса.
    if (delay != null) await Future.delayed(delay);

    final FutureOr<T> futureOr = function();

    final T response;

    switch (minExecutionTime) {
      case null:
        response = switch (futureOr) {
          Future() => await futureOr,
          _ => futureOr,
        };

      case Duration():
        try {
          final res = await (Future(() => futureOr), Future.delayed(minExecutionTime)).wait;

          response = res.$1;
        } catch (e) {
          switch (e) {
            case ParallelWaitError(errors: (AsyncError(error: final e, stackTrace: final s), _)):
              throw Error.throwWithStackTrace(e, s);
          }

          rethrow;
        }
    }

    return response;
  }

  FutureOr<T> _wrapWithRetry<T>({
    required Retry? retry,
    required FutureOr<T> Function() function,
  }) async {
    final finalRetry = retry ?? Retry.none();
    final futureOr = finalRetry.execute<T>(
      (_) => function(),
    );

    return futureOr;
  }

  // Обёртываем запрос через RateLimiter, если задан.
  FutureOr<D?> _wrapWithRateLimiter<D>({
    required RateOperationsContainer container,
    required RateLimiter? rateLimiter,
    required Object? tag,
    required OnError<BaseResponseError, D?>? onError,
    required FutureOr<D?> Function() function,
  }) async {
    if (rateLimiter != null) {
      final res = await rateLimiter.process<D?>(
        function,
        tag: tag ?? '$hashCode${StackTrace.current}',
        container: container,
      );

      switch (res) {
        case RateOperationSuccess<D?>():
          return res.data;
        case RateOperationCancel<D?>(key: final key, :final timings):
          return onError?.call(
            CancelError<BaseResponseError>(
              key: key,
              stackTrace: StackTrace.current,
              rateLimiter: rateLimiter,
              timings: timings,
            ),
          );
      }
    }

    return function();
  }
}
