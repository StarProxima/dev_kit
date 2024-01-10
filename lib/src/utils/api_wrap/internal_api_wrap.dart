import 'dart:async';

import 'package:dio/dio.dart';

import 'models/api_error.dart';
import 'rate_limiter.dart';
import 'rate_operation.dart';
import 'retry.dart';

typedef ExecuteIf = FutureOr<bool> Function();

typedef ParseError<ErrorType> = ErrorType Function(Object error);

class InternalApiWrap<ErrorType> {
  InternalApiWrap({
    required Retry retry,
    ParseError<ErrorType>? parseError,
  })  : _retry = retry,
        _parseError = parseError;

  final Retry _retry;
  final ParseError<ErrorType>? _parseError;

  /// Операции debounce и thottle, доступные по тегу.
  final Map<String, RateOperation> _operations = {};

  /// Находит операцию по [tag], немедленно выполняет её, если она есть.
  void fireOperation(String tag) => _operations.remove(tag)?.complete();

  /// Находит операцию по [tag] и отменяет её.
  void cancelOperation(String tag) => _operations.remove(tag)?.cancel();

  /// Отменяет все операции.
  void cancelAllOperations() => _operations.keys.forEach(cancelOperation);

  Future<D?> call<T, D>(
    FutureOr<T> Function() function, {
    FutureOr<D?> Function(T)? onSuccess,
    FutureOr<D?> Function(ApiError<ErrorType> error)? onError,
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

    ApiError<ErrorType> error;

    if (delay != null) await Future.delayed(delay);

    var attempt = 0;
    while (true) {
      attempt++;
      try {
        final T response;

        if (rateLimiter != null && attempt == 1) {
          final res = await rateLimiter.process(_operations, () async {
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
          error = ErrorResponse(
            statusCode: res.statusCode ?? 0,
            error: _parseError?.call(res.data) ?? res.data,
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
