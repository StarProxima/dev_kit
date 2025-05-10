import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import 'retry_stats.dart';

/// Function type that determines whether to retry based on error and retry statistics.
typedef RetryIfFn = FutureOr<bool> Function(
    Object e, StackTrace s, RetryStats stats);

/// Class providing predefined retry condition strategies.
abstract class RetryIf {
  /// Always retry regardless of the error type.
  static bool always(Object e, StackTrace s, RetryStats stats) => true;

  /// Never retry, always fail on first error.
  static bool never(Object e, StackTrace s, RetryStats stats) => false;

  /// Retry only for network/connection related errors.
  static bool badConnection(Object e, StackTrace s, RetryStats stats) {
    return switch (e) {
      DioException(type: DioExceptionType.badResponse) => false,
      DioException(requestOptions: RequestOptions(method: 'GET')) => true,
      SocketException() => true,
      _ => false,
    };
  }
}

/// Exception that can be thrown to explicitly request a retry attempt.
class RequestRetryException implements Exception {
  /// Optional message explaining why a retry is needed.
  final String? message;

  const RequestRetryException([this.message]);

  @override
  String toString() =>
      'RequestRetryException${message != null ? ': $message' : ''}';
}
