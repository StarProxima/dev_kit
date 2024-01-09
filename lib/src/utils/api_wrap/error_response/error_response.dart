// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_response.freezed.dart';

sealed class ErrorResponse<ErrorType> implements Exception {}

@freezed
class RequestError<ErrorType> extends ErrorResponse<ErrorType>
    with _$RequestError<ErrorType> {
  factory RequestError({
    required ErrorType error,
    required int statusCode,
    required String method,
    required Uri url,
    required StackTrace stackTrace,
  }) = _RequestError;
}

@freezed
class InternalError<ErrorType> extends ErrorResponse<ErrorType>
    with _$InternalError {
  factory InternalError({
    required Object error,
    required StackTrace stackTrace,
  }) = _InternalError;
}
