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
  ApiError<ErrorType> parseError(Object e, StackTrace s) {
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
    FutureOr<D?> Function(T)? onSuccess,
    OnError<ErrorType, D?>? onError,
    Duration? minExecutionTime,
    Duration? delay,
    RateLimiter? rateLimiter,
    Retry? retry,
  }) async {
    final fn = _wrapWithRateLimiter(
      rateLimiter: rateLimiter,
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
      final T response = await function();

      // Возвращаем успешный результат или непосредственно сам ответ.
      final successResult = (await onSuccess?.call(response)) ??
          (response is D ? response as D : null);

      return successResult;
    } catch (e, s) {
      final err = parseError(e, s);

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
      case null || Duration.zero:
        response =
            switch (futureOr) { Future() => await futureOr, _ => futureOr };
      case Duration():
        try {
          final res = await (
            Future(() => futureOr),
            Future.delayed(minExecutionTime)
          ).wait;

          response = res.$1;
        } catch (e) {
          switch (e) {
            case ParallelWaitError(
                errors: (AsyncError(error: final e, stackTrace: final s), _)
              ):
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
    required OnError<ErrorType, D?>? onError,
  }) async {
    if (rateLimiter != null) {
      final res = await rateLimiter.process<D?>(
        container: _operationsContainer,
        function: function,
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
            RateLimiterError<ErrorType>(
              rateLimiter: rateLimiter,
              tag: tag,
              timings: timings,
            ),
          );
      }
    }

    return function();
  }
}
