part of 'api_wrap.dart';

typedef ParseError<ErrorType> = ErrorType Function(Object error);

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
    Duration? delay,
    RateLimiter<D?>? rateLimiter,
    Retry<ErrorType>? retry,
    required bool shouldThrowOnError,
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
              statusCode: res.statusCode ?? 0,
              error: _parseError?.call(res.data) ?? res.data,
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

        if (attempt <= maxAttempts && await retryIf(error)) {
          final delay = finalRetry.calculateDelay(attempt);
          if (kDebugMode) {
            logger.debug('Retry', 'Attempt: $attempt, delay: $delay');
          }
          await Future.delayed(delay);
          continue;
        }

        if (onError != null) return onError(error);
        return shouldThrowOnError ? throw error : null;
      }
    }

    if (rateLimiter != null) {
      final res = await rateLimiter.process<D?>(
        container: _operationsContainer,
        function: fn,
        defaultTag: '$hashCode${StackTrace.current}',
      );

      switch (res) {
        case RateOperationSuccess<D?>():
          return res.data;
        case RateOperationCancel<D?>():
          return shouldThrowOnError ? throw res : null;
      }
    }

    return fn();
  }
}
