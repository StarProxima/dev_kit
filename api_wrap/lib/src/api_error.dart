part of 'api_wrap.dart';

sealed class ApiError<ErrorType> implements Exception {
  const ApiError();
}

class ErrorResponse<ErrorType> extends ApiError<ErrorType> {
  const ErrorResponse({
    required this.error,
    required this.statusCode,
    required this.method,
    required this.url,
    required this.stackTrace,
  });

  final ErrorType error;
  final int statusCode;
  final String method;
  final Uri url;
  final StackTrace stackTrace;

  @override
  String toString() =>
      'ErrorResponse:\n$statusCode $method $url\n\n$error\n\n$stackTrace';
}

class InternalError<ErrorType> extends ApiError<ErrorType> {
  InternalError({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() => 'InternalError:\n\n$error\n\n$stackTrace';
}

class RateCancelError<ErrorType> implements ApiError<ErrorType> {
  const RateCancelError({
    required this.rateLimiter,
    required this.tag,
    required this.timings,
  });

  final String rateLimiter;
  final String tag;
  final RateTimings timings;

  @override
  String toString() =>
      'RateCancelError: Operation was canceled by $rateLimiter. Remaining time: ${timings.remainingTime}. Operation tag:\n$tag';
}
