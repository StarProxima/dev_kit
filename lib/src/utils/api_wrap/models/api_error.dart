import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error.freezed.dart';

sealed class ApiError<ErrorType> implements Exception {
  const ApiError();
}

@freezed
class ErrorResponse<ErrorType> extends ApiError<ErrorType>
    with _$ErrorResponse<ErrorType> {
  factory ErrorResponse({
    required ErrorType error,
    required int statusCode,
    required String method,
    required Uri url,
    required StackTrace stackTrace,
  }) = _ErrorResponse;

  @override
  String toString() =>
      'ErrorResponse{\n  error: $error,\n  statusCode: $statusCode,\n  method: $method,\n  url: $url,\n  stackTrace: $stackTrace\n}';
}

@freezed
class InternalError<ErrorType> extends ApiError<ErrorType>
    with _$InternalError {
  factory InternalError({
    required Object error,
    required StackTrace stackTrace,
  }) = _InternalError;

  @override
  String toString() =>
      'InternalError{\n  error: $error,\n  stackTrace: $stackTrace\n}';
}
