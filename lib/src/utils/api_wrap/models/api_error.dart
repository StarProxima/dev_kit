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
}

@freezed
class InternalError<ErrorType> extends ApiError<ErrorType>
    with _$InternalError {
  factory InternalError({
    required Object error,
    required StackTrace stackTrace,
  }) = _InternalError;
}

extension ErrorResponseX on ErrorResponse {
  String toDescription() =>
      'ErrorResponse{\nerror: $error, \nstatusCode: $statusCode, \nmethod: $method, \nurl: $url, \nstackTrace: $stackTrace\n}';
}

extension InternalErrorX on InternalError {
  String toDescription() =>
      'InternalError{\nerror: $error, \nstackTrace: $stackTrace\n}';
}
