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
        _operationsContainer = container;

  final Retry<ErrorType> _retry;
  final ParseError<ErrorType>? _parseError;

  /// Контейнер операций, хранящий throttle и debounce операции по тегу.
  final RateOperationsContainer _operationsContainer;

  /// Преобразует исключение в специализированный [ApiError<ErrorType>].
  /// Обрабатывает различные типы ошибок, включая DioException.
  ApiError<ErrorType> wrapError(Object error, StackTrace stackTrace) {
    // Если ошибка уже ApiError с правильным типом, возвращаем как есть
    if (error is ApiError<ErrorType>) {
      return error;
    }

    // Обработка ошибок Dio
    if (error is DioException) {
      final res = error.response;
      if (res != null) {
        return ErrorResponse<ErrorType>(
          error: _parseError?.call(res.data) ?? res.data,
          stackTrace: stackTrace,
          data: error.requestOptions.data,
          statusCode: res.statusCode ?? 0,
          method: res.requestOptions.method,
          url: res.requestOptions.uri,
        );
      }
    }

    // Для всех остальных типов ошибок
    return InternalError<ErrorType>(error: error, stackTrace: stackTrace);
  }

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

    // Обрабатываем начальную задержку запроса.
    if (delay != null) await Future.delayed(delay);

    // Функция для выполнения запроса с учетом минимального времени выполнения
    Future<T> executeWithMinTime() async {
      // Обработка минимального времени выполнения запроса.
      if (minExecutionTime == null) {
        return await function();
      }

      final futureOr = function();
      final future = switch (futureOr) {
        Future() => futureOr,
        _ => Future.value(futureOr),
      };

      final rec = await Future.wait(
        [future, Future.delayed(minExecutionTime)],
      );

      return rec.first as T;
    }

    // Функция-обертка для выполнения запроса и обработки ответа
    Future<D?> executeRequest() async {
      try {
        final T response = await finalRetry.retry<T>(
          executeWithMinTime,
          wrapError: wrapError,
        );

        // Возвращаем успешный результат или непосредственно сам ответ.
        return (await onSuccess?.call(response)) ??
            (response is D ? response as D : null);
      } on ApiError<ErrorType> catch (e) {
        // Обработка ошибок из ретрая или возникших вне его
        return onError?.call(e);
      }
    }

    // Обёртываем запрос через RateLimiter, если задан.
    if (rateLimiter != null) {
      final res = await rateLimiter.process<D?>(
        container: _operationsContainer,
        function: executeRequest,
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
            RateCancelError<ErrorType>(
              rateLimiter: rateLimiter,
              tag: tag,
              timings: timings,
            ),
          );
      }
    }

    return executeRequest();
  }
}
