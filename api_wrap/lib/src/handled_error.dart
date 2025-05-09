import 'package:dio/dio.dart';

import 'rate_limiter/core/rate_timings.dart';
import 'rate_limiter/rate_limiter.dart';

sealed class HandledError<BaseResponseError> implements Exception {
  const HandledError();

  String toStringWithStackTrace();
}

class ErrorResponse<BaseResponseError> extends HandledError<BaseResponseError> {
  const ErrorResponse({
    required this.error,
    required this.stackTrace,
    required this.dioException,
  });

  final BaseResponseError error;
  final StackTrace stackTrace;
  final DioException dioException;

  int? get statusCode => dioException.response?.statusCode;
  dynamic get requestData => dioException.requestOptions.data;
  String get method => dioException.requestOptions.method;
  String get url => dioException.requestOptions.uri.toString();

  @override
  String toString() => 'ErrorResponse: $statusCode $method $url\n$error';

  @override
  String toStringWithStackTrace() => '${toString()}\n\n$stackTrace';
}

class InternalError<BaseResponseError> extends HandledError<BaseResponseError> {
  InternalError({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() => 'InternalError: $error';

  @override
  String toStringWithStackTrace() => '${toString()}\n\n$stackTrace';
}

class CancelError<BaseResponseError>
    implements HandledError<BaseResponseError> {
  const CancelError({
    required this.stackTrace,
    this.rateLimiter,
    this.timings,
  });

  CancelError.withStackTrace({
    this.rateLimiter,
    this.timings,
  }) : stackTrace = StackTrace.current;

  final StackTrace stackTrace;
  final RateLimiter? rateLimiter;
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
