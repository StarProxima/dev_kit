import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../api_wrap.dart';
import 'retry_stats.dart';

typedef RetryIfFn<ErrorType> = FutureOr<bool> Function(
    ApiError<ErrorType> e, RetryStats stats);

abstract class RetryIf {
  static bool always(ApiError e, RetryStats stats) => true;

  static bool never(ApiError e, RetryStats stats) => false;

  static bool badConnection(ApiError e, RetryStats stats) {
    if (e is! InternalError) return false;
    final error = e.error;
    return switch (error) {
      DioException(type: DioExceptionType.badResponse) => false,
      DioException(requestOptions: RequestOptions(method: 'GET')) => true,
      SocketException() => true,
      _ => false,
    };
  }
}

class ShouldRetry implements Exception {
  final String? message;

  ShouldRetry(this.message);

  @override
  String toString() => 'ShouldRetry${message != null ? ':$message' : ''}';
}
