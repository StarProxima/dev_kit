import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

part 'utils.dart';
part 'api_error.dart';
part 'api_wrapper.dart';
part 'api_wrap_controller.dart';
part 'internal_api_wrap.dart';
part 'rate_limiter.dart';
part 'rate_operation.dart';
part 'retry.dart';

extension ApiWrapX<ErrorType> on IApiWrap<ErrorType> {
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
  /// Возвращает Future<D?> с преобразованным значением, полученным либо от [onSuccess] либо от [onError].
  Future<D?> apiWrap<T, D>(
    FutureOr<T> Function() function, {
    FutureOr<D?> Function(T res)? onSuccess,
    OnError<ErrorType, D?>? onError,
    Duration? minExecutionTime,
    Duration? delay,
    Retry<ErrorType>? retry,
    RateLimiter? rateLimiter,
  }) =>
      _internalApiWrap<T, D>(
        function,
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
    required FutureOr<D> Function(T res) onSuccess,
    OnError<ErrorType, D>? onError,
    Duration? minExecutionTime,
    Duration? delay,
    Retry<ErrorType>? retry,
    RateLimiter? rateLimiter,
  }) async =>
      (await _internalApiWrap<T, D>(
        function,
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
    FutureOr<T?> Function(T res)? onSuccess,
    OnError<ErrorType, T?>? onError,
    Duration? minExecutionTime,
    Duration? delay,
    Retry<ErrorType>? retry,
    RateLimiter? rateLimiter,
  }) =>
      _internalApiWrap<T, T>(
        function,
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
    FutureOr<T> Function(T res)? onSuccess,
    OnError<ErrorType, T>? onError,
    Duration? minExecutionTime,
    Duration? delay,
    Retry<ErrorType>? retry,
    RateLimiter? rateLimiter,
  }) async =>
      (await _internalApiWrap<T, T>(
        function,
        onSuccess: onSuccess,
        onError: onError,
        minExecutionTime: minExecutionTime,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        shouldThrowError: true,
      )) as T;

  Future<D?> _internalApiWrap<T, D>(
    FutureOr<T> Function() function, {
    required FutureOr<D?> Function(T res)? onSuccess,
    required OnError<ErrorType, D?>? onError,
    required Duration? minExecutionTime,
    required Duration? delay,
    required Retry<ErrorType>? retry,
    required RateLimiter? rateLimiter,
    required bool shouldThrowError,
  }) =>
      wrapController.internalApiWrap.execute<T, D>(
        function,
        onSuccess: onSuccess,
        onError: onError ??
            (e) {
              this.onError(e);
              if (shouldThrowError) throw e;
              return null;
            },
        minExecutionTime: minExecutionTime,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
      );
}
