part of 'api_wrap.dart';

typedef ParseError<ErrorType> = ErrorType Function(Object? error);

/// Оболочка API для внутреннего использования, управляет повторными попытками,
/// ограничением частоты операций и обработкой ошибок.
class InternalApiWrap<ErrorType> {
  InternalApiWrap({
    required Retry<ErrorType> retry,
    required RateOperationsContainer container,
    ParseError<ErrorType>? parseError,
  })  : _retry = retry,
        _parseError = parseError,
        _operationsContainer = container {
    // Проверяем наличие обработчика ошибок, если тип ошибки был задан.
    if (parseError == null && ErrorType != dynamic) {
      throw ParseErrorMissingError();
    }
  }

  final Retry<ErrorType> _retry;
  final ParseError<ErrorType>? _parseError;

  /// Контейнер операций, хранящий throttle и debounce операции по тегу.
  final RateOperationsContainer _operationsContainer;

  @visibleForTesting
  Future<D?> execute<T, D>(
    FutureOr<T> Function() function, {
    FutureOr<D?> Function(T)? onSuccess,
    OnError<ErrorType, D?>? onError,
    Duration? minExecutionTime,
    Duration? delay,
    RateLimiter? rateLimiter,
    Retry<ErrorType>? retry,
  }) async {
    final finalRetry = retry ?? _retry;
    final maxAttempts = finalRetry.maxAttempts;
    final retryIf = finalRetry.retryIf;

    ApiError<ErrorType> error;

    // Обрабатываем начальную задержку запроса.
    if (delay != null) await Future.delayed(delay);

    Future<D?> fn() async {
      var attempt = 0;
      var isMinExecutionTimeUsed = false;
      while (true) {
        attempt++;
        try {
          final T response;

          // Обработка минимального времени выполнения запроса.
          if (minExecutionTime == null || isMinExecutionTimeUsed) {
            response = await function();
          } else {
            isMinExecutionTimeUsed = true;

            final futureOr = function();
            final future = switch (futureOr) {
              Future() => futureOr,
              _ => Future.value(futureOr),
            };
            final rec = await Future.wait(
              [future, Future.delayed(minExecutionTime)],
            );
            response = rec.first as T;
          }

          // Возвращаем успешный результат или непосредственно сам ответ.
          return (await onSuccess?.call(response)) ??
              (response is D ? response as D : null);
        } on DioException catch (e) {
          // Обработка ошибок Dio, включая парсинг ответа.
          final res = e.response;
          if (res != null) {
            error = ErrorResponse(
              error: _parseError?.call(res.data) ?? res.data,
              stackTrace: e.stackTrace,
              data: e.requestOptions.data,
              statusCode: res.statusCode ?? 0,
              method: res.requestOptions.method,
              url: res.requestOptions.uri,
            );
          } else {
            error = InternalError(error: e, stackTrace: e.stackTrace);
          }
        } on ApiError<ErrorType> catch (e) {
          error = e;
        } catch (e, s) {
          // Обработка неопределенных ошибок.
          error = InternalError(error: e, stackTrace: s);
        }

        // Попытка повтора запроса в соответствии с заданными параметрами.
        if (attempt < maxAttempts && await retryIf(error)) {
          final delay = finalRetry.calculateDelay(attempt);
          await Future.delayed(delay);
          continue;
        }

        // Возвращаем результат вызова функции обработки ошибок, если она задана.
        return onError?.call(error);
      }
    }

    // Обёртываем запрос через RateLimiter, если задан.
    if (rateLimiter != null) {
      final res = await rateLimiter.process<D?>(
        container: _operationsContainer,
        function: fn,
        defaultTag: '$hashCode${StackTrace.current}',
      );

      switch (res) {
        case RateOperationSuccess<D?>():
          return res.data;
        case RateOperationCancel<D?>(
            :final rateLimiter,
            :final tag,
            :final timings
          ):
          return onError?.call(
            RateCancelError(
              rateLimiter: rateLimiter,
              tag: tag,
              timings: timings,
            ),
          );
      }
    }

    return fn();
  }
}
