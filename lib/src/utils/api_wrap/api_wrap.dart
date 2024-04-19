import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../internal/logger/dev_kit_logger.dart';

part 'annotations.dart';
part 'api_error.dart';
part 'api_wrap_controller.dart';
part 'internal_api_wrap.dart';
part 'rate_limiter.dart';
part 'rate_operation.dart';
part 'retry.dart';

/// {@template [ApiWrapper]}
/// Предоставляет утилиты и обёртки для [Dio] запросов и обычных функций.
///
/// Даёт возможность реализовать автоматическую обработку ошибок (логгирование и показ тостов) с возможность отлючения.
/// Предоставляет методы для обработки успешного и ошибочного ответа API.
/// {@endtemplate}
class ApiWrapper<ErrorType> implements IApiWrap<ErrorType> {
  /// {@macro [ApiWrapper]}
  ApiWrapper({
    required FutureOr<void> Function(ApiError<ErrorType> error) onError,
    ApiWrapController<ErrorType>? options,
  })  : _handleError = onError,
        wrapController = options ?? ApiWrapController<ErrorType>();

  @override
  final ApiWrapController<ErrorType> wrapController;

  final FutureOr<void> Function(ApiError<ErrorType> error) _handleError;

  @override
  FutureOr<void> handleError(ApiError<ErrorType> error) => _handleError(error);
}

// /// Тип колбека, используемый для обработки ошибок API.
// typedef OnError<ErrorType> = FutureOr<D?> Function<D>(
//   ApiError<ErrorType> error,
// );

abstract class IApiWrap<ErrorType> {
  FutureOr<void> handleError(ApiError<ErrorType> error);

  @protected
  abstract final ApiWrapController<ErrorType> wrapController;
}

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
    FutureOr<D?> Function(ApiError<ErrorType> error)? onError,
    Duration? delay,
    Retry<ErrorType>? retry,
    RateLimiter? rateLimiter,
  }) =>
      _internalApiWrap<T, D>(
        function,
        onSuccess: onSuccess,
        onError: onError,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
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
    FutureOr<D> Function(ApiError<ErrorType> error)? onError,
    Duration? delay,
    Retry<ErrorType>? retry,
  }) async =>
      (await _internalApiWrap<T, D>(
        function,
        onSuccess: onSuccess,
        onError: onError ?? (e) => throw e,
        delay: delay,
        retry: retry,
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
    FutureOr<T?> Function(ApiError<ErrorType> error)? onError,
    Duration? delay,
    Retry<ErrorType>? retry,
    RateLimiter? rateLimiter,
  }) =>
      _internalApiWrap<T, T>(
        function,
        onSuccess: onSuccess,
        onError: onError,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
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
    FutureOr<T> Function(ApiError<ErrorType> error)? onError,
    Duration? delay,
    Retry<ErrorType>? retry,
  }) async =>
      (await _internalApiWrap<T, T>(
        function,
        onSuccess: onSuccess,
        onError: onError ?? (e) => throw e,
        delay: delay,
        retry: retry,
      )) as T;

  Future<D?> _internalApiWrap<T, D>(
    FutureOr<T> Function() function, {
    FutureOr<D?> Function(T res)? onSuccess,
    FutureOr<D?> Function(ApiError<ErrorType> error)? onError,
    Duration? delay,
    Retry<ErrorType>? retry,
    RateLimiter? rateLimiter,
  }) =>
      wrapController.internalApiWrap.execute<T, D>(
        function,
        onSuccess: onSuccess,
        onError: onError ??
            (e) {
              handleError(e);
              return null;
            },
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
      );
}
