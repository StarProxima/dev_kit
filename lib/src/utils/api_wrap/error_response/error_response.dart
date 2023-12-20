// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'error_response.freezed.dart';

sealed class ErrorResponse implements Exception {}

@freezed
class RequestError extends ErrorResponse with _$RequestError {
  factory RequestError({
    required Object error,
    required int statusCode,
    required String method,
    required Uri url,
    required StackTrace stackTrace,
  }) = _RequestError;
}

@freezed
class InternalError extends ErrorResponse with _$InternalError {
  factory InternalError({
    required Object error,
    required StackTrace stackTrace,
  }) = _InternalError;
}
