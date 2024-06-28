part of 'api_wrap.dart';

typedef ParseError<ErrorType> = ErrorType Function(Object? error);

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

  /// Операции debounce и thottle, доступные по тегу.
  final RateOperationsContainer _operationsContainer;

  @visibleForTesting
  Future<D?> execute<T, D>(
    FutureOr<T> Function() function, {
    FutureOr<D?> Function(T)? onSuccess,
    FutureOr<D?> Function(ApiError<ErrorType> error)? onError,
    Duration? minExecutionTime,
    Duration? delay,
    RateLimiter? rateLimiter,
    Retry<ErrorType>? retry,
  }) async {
    final finalRetry = retry ?? _retry;
    final maxAttempts = finalRetry.maxAttempts;
    final retryIf = finalRetry.retryIf;

    ApiError<ErrorType> error;

    if (delay != null) await Future.delayed(delay);

    Future<D?> fn() async {
      var attempt = 0;
      while (true) {
        attempt++;
        try {
          final T response;

          response = await function();

          return (await onSuccess?.call(response)) ??
              (response is D ? response as D : null);
        } on DioException catch (e) {
          final res = e.response;
          if (res != null) {
            error = ErrorResponse(
              error: _parseError?.call(res.data) ?? res.data,
              data: e.requestOptions.data,
              statusCode: res.statusCode ?? 0,
              method: res.requestOptions.method,
              url: res.requestOptions.uri,
              stackTrace: e.stackTrace,
            );
          } else {
            error = InternalError(error: e, stackTrace: e.stackTrace);
          }
        } on ApiError<ErrorType> catch (e) {
          error = e;
        } catch (e, s) {
          error = InternalError(error: e, stackTrace: s);
        }

        if (attempt < maxAttempts && await retryIf(error)) {
          final delay = finalRetry.calculateDelay(attempt);
          await Future.delayed(delay);
          continue;
        }

        return onError?.call(error);
      }
    }

    Future<D?> minExecutionTimeFn() async {
      if (minExecutionTime == null) return fn();

      final rec = await Future.wait(
        [fn(), Future.delayed(minExecutionTime)],
      );

      return rec.first as D?;
    }

    if (rateLimiter != null) {
      final res = await rateLimiter.process<D?>(
        container: _operationsContainer,
        function: minExecutionTimeFn,
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

    return minExecutionTimeFn();
  }
}
