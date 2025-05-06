import 'dart:async';

import 'package:api_wrap/src/retry/retry.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

import 'rate_limiter/rate_limiter.dart';
import 'rate_limiter/rate_operation.dart';
import 'rate_limiter/utils.dart';

part 'utils.dart';
part 'api_error.dart';
part 'api_wrapper.dart';
part 'api_wrap_controller.dart';
part 'internal_api_wrap.dart';

extension ApiWrapX<BaseResponseError> on IApiWrap<BaseResponseError> {
  /// Обёртывает HTTP запрос через [Dio] или обычную функцию, позволяя преобразовывать тип данных.
  /// Предоставляет возможность использования последовательных вложенных запросов и
  /// автоматической или ручной обработки ошибок.
  ///
  /// [function] - API запрос или функция, возвращающая значение типа [T].
  ///
  /// [onSuccess] - функция, вызываемая при успешном ответе, возможно, преобразующая [T] в [D].
  ///
  /// [onError] - функция для обработки ошибок, с возможным возвращаемым значением типа [D].
  ///
  /// [delay] - задержка перед выполнением запроса.
  ///
  /// [retry] - настройки повторных попыток выполнения запроса.
  /// Если не указано, то повторных попыток не будет.
  ///
  /// [maxExecutionTime] - максимальное общее время выполнения запроса, включая все повторные попытки.
  ///
  /// Возвращает Future<D?> с преобразованным значением, полученным либо от [onSuccess] либо от [onError].
  Future<D?> apiWrap<T, D>(
    FutureOr<T> Function() function, {
    Object? tag,
    Duration? delay,
    Duration? minExecutionTime,
    Retry? retry,
    RateLimiter? rateLimiter,
    FutureOr<D?> Function(T res)? onSuccess,
    OnError<BaseResponseError, D?>? onError,
  }) =>
      _internalApiWrap<T, D>(
        function,
        tag: tag,
        onSuccess: onSuccess,
        onError: onError,
        minExecutionTime: minExecutionTime,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        shouldThrowError: false,
      );

  /// Строгая версия [apiWrap], требующая обязательного определения [onSuccess].
  /// Если [onError] не задан, будет вызвано исключение при возникновении ошибки.
  /// Это позволяет возвращать ненулевой тип.
  ///
  /// [function] - API запрос или функция, возвращающая значение типа [T].
  /// [onSuccess] - обязательная функция, преобразующая [T] в [D] при успешном ответе.
  /// [onError] - необязательная функция для обработки ошибок, возвращающая [T].
  ///
  /// Возвращает Future с ненулевым результатом типа [D].
  Future<D> apiWrapStrict<T, D>(
    FutureOr<T> Function() function, {
    Object? tag,
    Duration? delay,
    Duration? minExecutionTime,
    Retry? retry,
    RateLimiter? rateLimiter,
    required FutureOr<D> Function(T res) onSuccess,
    OnError<BaseResponseError, D>? onError,
  }) async =>
      (await _internalApiWrap<T, D>(
        function,
        tag: tag,
        onSuccess: onSuccess,
        onError: onError,
        minExecutionTime: minExecutionTime,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        shouldThrowError: true,
      )) as D;

  /// Версия [apiWrap] c единым типом данных.
  /// Применяется, когда входной и выходной типы функции совпадают.
  ///
  /// [function] - API запрос или функция, возвращающая значение типа [T].
  ///
  /// [onSuccess] - функция, вызываемая при успешном ответе, с необязательным возвращаемым типом [T].
  ///
  /// [onError] - функция для обработки ошибок, с необязательным возвращаемым типом [T].
  ///
  /// Возвращает Future<T?> со значением, полученным либо от [function],
  /// либо от [onSuccess], если он задан, либо от [onError] при ошибке.
  Future<T?> apiWrapSingle<T>(
    FutureOr<T> Function() function, {
    Object? tag,
    Duration? delay,
    Duration? minExecutionTime,
    Retry? retry,
    RateLimiter? rateLimiter,
    FutureOr<T?> Function(T res)? onSuccess,
    OnError<BaseResponseError, T?>? onError,
  }) =>
      _internalApiWrap<T, T>(
        function,
        tag: tag,
        onSuccess: onSuccess,
        onError: onError,
        minExecutionTime: minExecutionTime,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        shouldThrowError: false,
      );

  /// Строгая версия [apiWrap] c единым типом данных.
  /// Если [onError] не задан, будет вызвано исключение при возникновении ошибки.
  /// Это позволяет возвращать ненулевой тип.
  ///
  /// [function] - API запрос или функция, возвращающая [T].
  /// [onSuccess] - функция, вызываемая при успешном ответе, возвращающая [T].
  /// [onError] - функция для обработки ошибок, возвращающая [T].
  ///
  /// Возвращает Future с ненулевым результатом типа [T].
  Future<T> apiWrapStrictSingle<T>(
    FutureOr<T> Function() function, {
    Object? tag,
    Duration? delay,
    Duration? minExecutionTime,
    Retry? retry,
    RateLimiter? rateLimiter,
    FutureOr<T> Function(T res)? onSuccess,
    OnError<BaseResponseError, T>? onError,
  }) async =>
      (await _internalApiWrap<T, T>(
        function,
        tag: tag,
        onSuccess: onSuccess,
        onError: onError,
        minExecutionTime: minExecutionTime,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        shouldThrowError: true,
      )) as T;

  HandledError<BaseResponseError> wrapError(Object e, StackTrace s) => wrapController.internalApiWrap.wrapError(e, s);

  Future<D?> _internalApiWrap<T, D>(
    FutureOr<T> Function() function, {
    Object? tag,
    Duration? delay,
    Duration? minExecutionTime,
    Retry? retry,
    RateLimiter? rateLimiter,
    required bool shouldThrowError,
    required FutureOr<D?> Function(T res)? onSuccess,
    required OnError<BaseResponseError, D?>? onError,
  }) =>
      wrapController.internalApiWrap.execute<T, D>(
        function,
        tag: tag,
        delay: delay,
        minExecutionTime: minExecutionTime,
        retry: retry,
        rateLimiter: rateLimiter,
        onSuccess: onSuccess,
        onError: onError ??
            (e) {
              this.onError(e);
              if (shouldThrowError) throw e;
              return null;
            },
      );
}
