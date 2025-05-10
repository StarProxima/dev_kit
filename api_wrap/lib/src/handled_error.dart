import 'package:dio/dio.dart';

import 'rate_limiter/core/rate_timings.dart';
import 'rate_limiter/rate_limiter.dart';

/// Base class for all handled errors in the API wrapper.
///
/// Provides a common interface for different types of errors that can occur
/// during API requests, allowing for consistent error handling patterns.
sealed class HandledError<BaseResponseError> implements Exception {
  const HandledError();

  /// Returns a string representation of the error with its stack trace.
  ///
  /// Useful for detailed logging and debugging.
  String toStringWithStackTrace();
}

/// Error from a server response with a parsed error payload.
///
/// Represents an error received from the API with a structured error body
/// that has been parsed into the application-specific BaseResponseError type.
class ErrorResponse<BaseResponseError> extends HandledError<BaseResponseError> {
  const ErrorResponse({
    required this.error,
    required this.stackTrace,
    required this.dioException,
  });

  /// The parsed error response from the server.
  final BaseResponseError error;

  /// Stack trace at the point where the error was captured.
  final StackTrace stackTrace;

  /// The original Dio exception that occurred during the request.
  final DioException dioException;

  /// HTTP status code of the response (if available).
  int? get statusCode => dioException.response?.statusCode;

  /// Data sent in the request.
  dynamic get requestData => dioException.requestOptions.data;

  /// HTTP method used for the request.
  String get method => dioException.requestOptions.method;

  /// URL that was requested.
  String get url => dioException.requestOptions.uri.toString();

  @override
  String toString() => 'ErrorResponse: $statusCode $method $url\n$error';

  @override
  String toStringWithStackTrace() => '${toString()}\n\n$stackTrace';
}

/// Error that occurred within the client code, not related to API communication.
///
/// Represents exceptions thrown during request preparation, response processing,
/// or other internal operations not directly related to network communication.
class InternalError<BaseResponseError> extends HandledError<BaseResponseError> {
  InternalError({
    required this.error,
    required this.stackTrace,
  });

  /// The original error object.
  final Object error;

  /// Stack trace at the point where the error was captured.
  final StackTrace stackTrace;

  @override
  String toString() => 'InternalError: $error';

  @override
  String toStringWithStackTrace() => '${toString()}\n\n$stackTrace';
}

/// Error indicating that an operation was canceled.
///
/// Represents situations where an API request was canceled, either manually
/// or through a rate limiting mechanism like debounce or throttle.
class CancelError<BaseResponseError>
    implements HandledError<BaseResponseError> {
  const CancelError({
    required this.stackTrace,
    this.rateLimiter,
    this.timings,
  });

  /// Creates a cancel error with the current stack trace.
  CancelError.withStackTrace({
    this.rateLimiter,
    this.timings,
  }) : stackTrace = StackTrace.current;

  /// Stack trace at the point where the cancellation occurred.
  final StackTrace stackTrace;

  /// The rate limiter that caused the cancellation, if applicable.
  final RateLimiter? rateLimiter;

  /// Timing information related to the rate limiting, if applicable.
  final RateTimings? timings;

  String _toRateLimiterString() => rateLimiter != null
      ? ' RateLimiter: ${rateLimiter.runtimeType}, $timings.'
      : '';

  @override
  String toString() =>
      'CancelError: Handle was canceled.${_toRateLimiterString()}';

  @override
  String toStringWithStackTrace() => '${toString()}\n\n$stackTrace';
}
