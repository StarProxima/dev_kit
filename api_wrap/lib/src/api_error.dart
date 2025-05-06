part of 'api_wrap.dart';

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
  String toStringWithStackTrace() => 'ErrorResponse:\n$statusCode $method $url\n$error\n$stackTrace';
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
  String toStringWithStackTrace() => 'InternalError:\n$error\n$stackTrace';
}

class RateLimiterError<BaseResponseError> implements HandledError<BaseResponseError> {
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
