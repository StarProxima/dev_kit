part of 'api_wrap.dart';

sealed class ApiError<BaseHttpErrorType> implements Exception {
  const ApiError();

  String toStringWithStackTrace();
}

class ErrorResponse<BaseHttpErrorType> extends ApiError<BaseHttpErrorType> {
  const ErrorResponse({
    required this.error,
    required this.stackTrace,
    required this.data,
    required this.statusCode,
    required this.method,
    required this.url,
  });

  final BaseHttpErrorType error;
  final StackTrace stackTrace;
  final int statusCode;
  final dynamic data;
  final String method;
  final Uri url;

  @override
  String toString() => 'ErrorResponse: $statusCode $method $url\n$error';

  @override
  String toStringWithStackTrace() => 'ErrorResponse:\n$statusCode $method $url\n$error\n$stackTrace';
}

class InternalError<BaseHttpErrorType> extends ApiError<BaseHttpErrorType> {
  InternalError({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() => 'InternalError: $error';

  @override
  String toStringWithStackTrace() => 'InternalError:\n$error\n$stackTrace';
}

class RateLimiterError<BaseHttpErrorType> implements ApiError<BaseHttpErrorType> {
  const RateLimiterError({
    required this.rateLimiter,
    required this.key,
    required this.timings,
  });

  final String rateLimiter;
  final Object key;
  final RateTimings timings;

  @override
  String toString() =>
      'RateLimiterError: Operation was canceled by $rateLimiter. Remaining time: ${timings.remainingTime}. Operation key:\n$key';

  @override
  String toStringWithStackTrace() =>
      'RateLimiterError: Operation was canceled by $rateLimiter. Remaining time: ${timings.remainingTime}. Operation key:\n$key';
}
