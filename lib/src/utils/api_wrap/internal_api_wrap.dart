import 'dart:async';

import 'package:dio/dio.dart';

import 'api_operation.dart';
import 'error_response/error_response.dart';
import 'rate_limiter.dart';
import 'retry.dart';

typedef ExecuteIf = FutureOr<bool> Function();

class InternalApiWrap {
  InternalApiWrap(this._retry);

  final Retry _retry;

  /// Операции debounce и thottle, доступные по тегу.
  final Map<String, ApiOperation> _operations = {};

  /// Находит операцию по [tag], немедленно выполняет её, если она есть.
  void fireOperation(String tag) => _operations.remove(tag)?.complete();

  /// Находит операцию по [tag] и отменяет её.
  void cancelOperation(String tag) => _operations.remove(tag)?.cancel();

  /// Отменяет все операции.
  void cancelAllOperations() => _operations.keys.forEach(cancelOperation);

  Future<D?> call<T, D>(
    FutureOr<T> Function() function, {
    FutureOr<D?> Function(T)? onSuccess,
    FutureOr<D?> Function(ErrorResponse error)? onError,
    Duration? delay,
    RateLimiter? rateLimiter,
    ExecuteIf? executeIf,
    Retry? retry,
  }) async {
    retry ??= _retry;
    final maxAttempts = retry.maxAttempts;
    final retryIf = retry.retryIf;

    FutureOr<bool> notExecuteIf() async =>
        executeIf != null && !(await executeIf());

    ErrorResponse error;

    if (delay != null) await Future.delayed(delay);

    var attempt = 0;
    while (true) {
      attempt++;
      try {
        final T response;

        if (rateLimiter != null && attempt == 1) {
          final res = await rateLimiter(_operations, () async {
            if (await notExecuteIf()) return null;
            return function();
          });
          if (res == null) return null;
          response = res;
        } else {
          if (await notExecuteIf()) return null;
          response = await function();
        }

        return (await onSuccess?.call(response)) ??
            (response is D ? response as D : null);
      } on DioException catch (e) {
        final res = e.response;
        if (res != null) {
          error = RequestError(
            statusCode: res.statusCode ?? 0,
            error: res.data,
            method: res.requestOptions.method,
            url: res.requestOptions.uri,
            stackTrace: e.stackTrace,
          );
        } else {
          error = InternalError(error: e, stackTrace: e.stackTrace);
        }
      } catch (e, s) {
        error = InternalError(error: e, stackTrace: s);
      }

      if (attempt <= maxAttempts && await retryIf(error)) {
        await Future.delayed(retry.calculateDelay(attempt));
        continue;
      }

      return onError?.call(error);
    }
  }
}
