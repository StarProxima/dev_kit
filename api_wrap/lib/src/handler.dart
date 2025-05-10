import 'dart:async';

import 'package:dio/dio.dart';

import 'handled_error.dart';
import 'handler_executor.dart';
import 'operations_container.dart';
import 'rate_limiter/rate_limiter.dart';
import 'retry/retry.dart';
import 'utils.dart';

/// Provides utilities and wrappers for [Dio] requests and regular functions.
///
/// Enables automatic error handling (logging and toast displays) with the ability to disable it.
/// Provides methods for handling successful and error API responses.
class Handler<BaseResponseError> {
  Handler({
    ParseBaseResponseError<BaseResponseError>? parseBaseResponseError,
    Retry? retry,
    OperationsContainer? container,
    GlobalOnError<BaseResponseError>? onError,
  })  : _parseBaseResponseError = parseBaseResponseError,
        _retry = retry,
        _onError = onError,
        _container = container ?? OperationsContainer(),
        _executor = HandlerExecutor<BaseResponseError>() {
    if (parseBaseResponseError == null) {
      final typeStr = BaseResponseError.toString();

      if (typeStr != 'dynamic' && typeStr != 'Object?') {
        throw ParseBaseResponseErrorMissingError();
      }
    }
  }

  final ParseBaseResponseError<BaseResponseError>? _parseBaseResponseError;
  final Retry? _retry;
  final HandlerExecutor<BaseResponseError> _executor;
  final GlobalOnError<BaseResponseError>? _onError;
  final OperationsContainer _container;

  /// {@template Handler.handle}
  /// Wraps an HTTP request via [Dio] or a regular function, allowing data type transformation.
  /// Provides the ability to use sequential nested requests and
  /// automatic or manual error handling.
  ///
  /// [function] - API request or function returning a value of type [T].
  ///
  /// [onSuccess] - function called on successful response, possibly transforming [T] to [D].
  ///
  /// [onError] - function for error handling, with possible return value of type [D].
  ///
  /// [delay] - delay before executing the request.
  ///
  /// [retry] - settings for request retry attempts.
  /// If not specified, no retries will be performed.
  ///
  /// Returns Future<D?> with the transformed value obtained either from [onSuccess] or [onError].
  /// {@endtemplate}
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
      _executor.execute<T, D>(
        function: function,
        key: key,
        container: _container,
        wrapError: wrapError,
        minExecutionTime: minExecutionTime,
        delay: delay,
        retry: retry ?? _retry,
        rateLimiter: rateLimiter,
        onSuccess: onSuccess,
        onError: onError ??
            (e) {
              this.onError(e);
              return null;
            },
      );

  /// {@template Handler.handleStrict}
  /// Strict version of [handle], requiring mandatory definition of [onSuccess].
  /// If [onError] is not specified, an exception will be thrown when an error occurs.
  /// This allows returning a non-null type.
  ///
  /// [function] - API request or function returning a value of type [T].
  /// [onSuccess] - mandatory function that transforms [T] to [D] on successful response.
  /// [onError] - optional function for error handling, returning [D].
  ///
  /// Returns a Future with a non-null result of type [D].
  /// {@endtemplate}
  Future<D> handleStrict<T, D>(
    FutureOr<T> Function() function, {
    Object? key,
    Duration? delay,
    Duration? minExecutionTime,
    Retry? retry,
    RateLimiter? rateLimiter,
    required FutureOr<D> Function(T res) onSuccess,
    OnError<BaseResponseError, D>? onError,
  }) async {
    final futureOr = _executor.execute<T, D>(
      function: function,
      key: key,
      container: _container,
      wrapError: wrapError,
      minExecutionTime: minExecutionTime,
      delay: delay,
      retry: retry ?? _retry,
      rateLimiter: rateLimiter,
      onSuccess: onSuccess,
      onError: onError ??
          (e) {
            this.onError(e);
            throw e;
          },
    );

    switch (futureOr) {
      case Future():
        return futureOr.then<D>((res) => res as D);

      case _:
        return futureOr as D;
    }
  }

  /// Transforms an exception into a specialized [HandledError<BaseResponseError>].
  /// Handles various error types, including DioException.
  HandledError<BaseResponseError> wrapError(Object e, StackTrace s) {
    final apiError = switch (e) {
      HandledError<BaseResponseError>() => e,
      DioException(response: Response res) => ErrorResponse<BaseResponseError>(
          error: _parseBaseResponseError?.call(res.data) ??
              res.data as BaseResponseError,
          stackTrace: s,
          dioException: e,
        ),
      _ => InternalError<BaseResponseError>(error: e, stackTrace: s),
    };

    return apiError;
  }

  /// Handles errors using the global error handler if provided
  FutureOr<void> onError(HandledError<BaseResponseError> error) =>
      _onError?.call(error);

  /// Executes an operation with the specified [key].
  ///
  /// If an operation exists for the given key:
  /// - throttle operation - cancels its cooldown period
  /// - debounce operation - executes it immediately
  ///
  /// Returns a [Future] that completes after all operations are started.
  Future<void> fire({required Object key}) => _container.fire(key: key);

  /// Executes all registered operations.
  ///
  /// Cancels the cooldown period for all throttle operations
  /// and immediately executes all debounce operations.
  ///
  /// Returns a [Future] that completes after all operations are started.
  Future<void> fireAll() => _container.fireAll();

  /// Cancels operations with the specified [key].
  ///
  /// If an operation exists for the given key:
  /// - debounce operation - cancels its execution
  /// - throttle operation - cancels its cooldown period
  void cancel({required Object key}) => _container.cancel(key: key);

  /// Cancels all registered operations.
  ///
  /// Cancels execution of all debounce operations and
  /// cooldown periods for all throttle operations.
  void cancelAll() => _container.cancelAll();
}
