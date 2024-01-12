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
      'ErrorResponse{\n  error: $error,\n  statusCode: $statusCode,\n  method: $method,\n  url: $url,\n  stackTrace: $stackTrace\n}';
}

class InternalError<ErrorType> extends ApiError<ErrorType> {
  InternalError({
    required this.error,
    required this.stackTrace,
  });

  final Object error;
  final StackTrace stackTrace;

  @override
  String toString() =>
      'InternalError{\n  error: $error,\n  stackTrace: $stackTrace\n}';
}
