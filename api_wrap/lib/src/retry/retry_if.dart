import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../api_wrap.dart';

typedef RetryIfFn<ErrorType> = FutureOr<bool> Function(ApiError<ErrorType> e);

abstract class RetryIf {
  static bool always(ApiError e) => true;

  static bool never(ApiError e) => false;

  static bool badConnection(ApiError e) {
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
