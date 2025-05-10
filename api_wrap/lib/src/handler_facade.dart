import 'dart:async';

import 'handler.dart';
import 'rate_limiter/rate_limiter.dart';
import 'retry/retry.dart';
import 'utils.dart';

abstract mixin class HandlerFacade<BaseResponseError> {
  Handler<BaseResponseError> get handler;
}

extension HandlerFacadeX<BaseResponseError>
    on HandlerFacade<BaseResponseError> {
  /// {@macro handler.handle}
  FutureOr<D?> handle<T, D>(
    FutureOr<T> Function() function, {
    Object? key,
    Duration? delay,
    Duration? minExecutionTime,
    Retry? retry,
    RateLimiter? rateLimiter,
    FutureOr<D?> Function(T res)? onSuccess,
    OnError<BaseResponseError, D?>? onError,
  }) =>
      handler.handle<T, D>(
        function,
        key: key,
        minExecutionTime: minExecutionTime,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        onSuccess: onSuccess,
        onError: onError,
      );

  /// {@macro handler.handleStrict}
  Future<D> handleStrict<T, D>(
    FutureOr<T> Function() function, {
    Object? key,
    Duration? delay,
    Duration? minExecutionTime,
    Retry? retry,
    RateLimiter? rateLimiter,
    required FutureOr<D> Function(T res) onSuccess,
    OnError<BaseResponseError, D>? onError,
  }) =>
      handler.handleStrict(
        function,
        key: key,
        minExecutionTime: minExecutionTime,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        onSuccess: onSuccess,
        onError: onError,
      );
}
