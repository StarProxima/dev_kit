import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../api_wrap.dart';
import 'retry_stats.dart';

/// Function type that determines whether to retry based on error and retry statistics.
typedef RetryIfFn<ErrorType> = FutureOr<bool> Function(
    ApiError<ErrorType> e, RetryStats stats);

/// Class providing predefined retry condition strategies.
abstract class RetryIf {
  /// Always retry regardless of the error type.
  static bool always(ApiError e, RetryStats stats) => true;

  /// Never retry, always fail on first error.
  static bool never(ApiError e, RetryStats stats) => false;

  /// Retry only for network/connection related errors.
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

/// Exception that can be thrown to explicitly request a retry attempt.
class ShouldRetry implements Exception {
  /// Optional message explaining why a retry is needed.
  final String? message;

  ShouldRetry(this.message);

  @override
  String toString() => 'ShouldRetry${message != null ? ':$message' : ''}';
}
