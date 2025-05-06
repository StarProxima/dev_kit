part of 'api_wrap.dart';

typedef ParseError<ErrorType> = ErrorType Function(Object? error);

/// Оболочка API для внутреннего использования, управляет повторными попытками,
/// ограничением частоты операций и обработкой ошибок.
class InternalApiWrap<ErrorType> {
  InternalApiWrap({
    required Retry retry,
    required RateOperationsContainer container,
    ParseError<ErrorType>? parseError,
  })  : _retry = retry,
        _parseError = parseError,
        _operationsContainer = container;

  final Retry _retry;
  final ParseError<ErrorType>? _parseError;

  /// Контейнер операций, хранящий throttle и debounce операции по тегу.
  final RateOperationsContainer _operationsContainer;

  /// Преобразует исключение в специализированный [ApiError<ErrorType>].
  /// Обрабатывает различные типы ошибок, включая DioException.
  ApiError<ErrorType> wrapError(Object e, StackTrace s) {
    final apiError = switch (e) {
      ApiError<ErrorType>() => e,
      DioException(response: Response res) => ErrorResponse<ErrorType>(
          error: _parseError?.call(res.data) ?? res.data,
          stackTrace: s,
          data: e.requestOptions.data,
          statusCode: res.statusCode ?? 0,
          method: res.requestOptions.method,
          url: res.requestOptions.uri,
        ),
      _ => InternalError<ErrorType>(error: e, stackTrace: s),
    };

    return apiError;
  }

  Future<D?> execute<T, D>(
    FutureOr<T> Function() function, {
    Object? tag,
    Duration? delay,
    Duration? minExecutionTime,
    Retry? retry,
    RateLimiter? rateLimiter,
    FutureOr<D?> Function(T)? onSuccess,
    OnError<ErrorType, D?>? onError,
  }) async {
    final fn = _wrapWithRateLimiter(
      rateLimiter: rateLimiter,
      tag: tag,
      onError: onError,
      function: () => _wrapWithCallbacks(
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
    required FutureOr<T> Function() function,
    required FutureOr<D?> Function(T)? onSuccess,
    required OnError<ErrorType, D?>? onError,
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
    required FutureOr<T> Function() function,
    required Duration? delay,
    required Duration? minExecutionTime,
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
    required FutureOr<T> Function() function,
    required Retry? retry,
  }) async {
    final finalRetry = retry ?? this._retry;
    final futureOr = finalRetry.execute<T>(
      (_) => function(),
    );

    return futureOr;
  }

  // Обёртываем запрос через RateLimiter, если задан.
  FutureOr<D?> _wrapWithRateLimiter<D>({
    required FutureOr<D?> Function() function,
    required RateLimiter? rateLimiter,
    required Object? tag,
    required OnError<ErrorType, D?>? onError,
  }) async {
    if (rateLimiter != null) {
      final res = await rateLimiter.process<D?>(
        function,
        tag: tag ?? '$hashCode${StackTrace.current}',
        container: _operationsContainer,
      );

      switch (res) {
        case RateOperationSuccess<D?>():
          return res.data;
        case RateOperationCancel<D?>(:final rateLimiter, key: final tag, :final timings):
          return onError?.call(
            RateLimiterError<ErrorType>(
              rateLimiter: rateLimiter,
              key: tag,
              timings: timings,
            ),
          );
      }
    }

    return function();
  }
}
