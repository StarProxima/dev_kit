import 'dart:async';

import 'package:meta/meta.dart';

import 'handled_error.dart';
import 'operations_container.dart';
import 'rate_limiter/rate_limiter.dart';
import 'rate_limiter/core/rate_operation.dart';
import 'retry/retry.dart';
import 'utils.dart';

/// Function for converting errors into standardized HandledError type.
///
/// Takes raw exceptions and stack traces and produces a properly typed
/// HandledError for consistent error handling.
typedef ProvideError<BaseResponseError> = HandledError<BaseResponseError>
    Function(Object error, StackTrace stackTrace);

/// API wrapper for internal use that manages retry attempts,
/// rate limiting operations, and error handling.
///
/// Provides a unified execution pipeline with configurable behaviors
/// for all API requests and operations.
@internal
class HandlerExecutor<BaseResponseError> {
  HandlerExecutor();

  /// Executes a function with all configured wrappers applied.
  ///
  /// This is the main execution method that composes various behaviors:
  /// - Rate limiting through the provided RateLimiter
  /// - Success and error callbacks
  /// - Initial delays and minimum execution time
  /// - Automatic retries for failed operations
  ///
  /// All these behaviors are applied in the correct order and can be
  /// configured individually.
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
    required OperationsContainer container,
    required ProvideError<BaseResponseError> wrapError,
  }) async {
    final fn = _wrapWithRateLimiter(
      container: container,
      rateLimiter: rateLimiter,
      key: key,
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

  /// Wrapper function for executing requests and handling responses.
  ///
  /// Handles the main try-catch block around the function execution:
  /// - Executes the function
  /// - Processes successful responses through onSuccess callback
  /// - Processes errors through onError callback
  /// - Converts raw errors to typed HandledError instances
  FutureOr<D?> _wrapWithCallbacks<T, D>({
    required ProvideError<BaseResponseError> wrapError,
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

      final result =
          onSuccessResponse ?? (response is D ? response as D : null);

      return result;
    } catch (e, s) {
      final err = wrapError(e, s);

      // Not awaiting to avoid catching exceptions in onError,
      // they will be caught on the next await
      final errorResult = onError?.call(err);

      return errorResult;
    }
  }

  /// Wrapper function for handling delays before and after function execution.
  ///
  /// Provides two types of timing controls:
  /// - Initial delay: Waits for a specified time before executing the function
  /// - Minimum execution time: Ensures the function appears to take at least
  ///   the specified amount of time to complete, useful for UI purposes
  FutureOr<T> _wrapWithDelays<T>({
    required Duration? delay,
    required Duration? minExecutionTime,
    required FutureOr<T> Function() function,
  }) async {
    // Process initial request delay
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

  /// Wrapper function for adding retry behavior to a function.
  ///
  /// Applies the retry logic to the function execution:
  /// - Uses the provided Retry instance or creates a no-retry instance if null
  /// - Automatically retries the function according to the retry policy
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

  /// Wrapper function for applying rate limiting to a function.
  ///
  /// Wraps the function with rate limiting logic if a rate limiter is provided:
  /// - Processes the function through the rate limiter
  /// - Handles successful results and cancelations
  /// - Generates appropriate CancelError when an operation is rate-limited
  FutureOr<D?> _wrapWithRateLimiter<D>({
    required OperationsContainer container,
    required RateLimiter? rateLimiter,
    required Object? key,
    required OnError<BaseResponseError, D?>? onError,
    required FutureOr<D?> Function() function,
  }) async {
    if (rateLimiter != null) {
      final res = await rateLimiter.process<D?>(
        function,
        key: key ?? '$hashCode${StackTrace.current}',
        container: container,
      );

      switch (res) {
        case RateOperationSuccess<D?>():
          return res.data;
        case RateOperationCancel<D?>(key: final _, :final timings):
          return onError?.call(
            CancelError<BaseResponseError>(
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
