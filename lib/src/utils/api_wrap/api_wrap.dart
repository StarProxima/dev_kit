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
    ApiWrapController<ErrorType>? opstions,
  }) : wrapController = opstions ?? ApiWrapController<ErrorType>();

  @override
  final ApiWrapController<ErrorType> wrapController;

  // После некототорго времени использования, пришёл к выводу, что лучше отказать от такой обработки ошибок.
  // Т.к. неотловленная ошибки не будут записываться в крашлитику, а полезность и удобство использования сомнительное
  @Deprecated('Use function instead')
  static Future<T> hideError<T>(
    FutureOr<T> Function() function, {
    bool? enabled,
  }) async {
    // Временно выключено для тестов
    enabled ??= false;

    if (!enabled) return function();

    try {
      final res = await function();
      return res;
    } catch (e, s) {
      return Future.error(e, s);
    }
  }
}

/// Тип колбека, используемый для обработки ошибок API.
typedef ErrorResponseOnError<ErrorType> = FutureOr<D?> Function<D>({
  required ApiError<ErrorType> error,
  required bool showErrorToast,
  required FutureOr<D?> Function(ApiError<ErrorType> error)? originalOnError,
});

abstract class IApiWrap<ErrorType> {
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
    RateLimiter<D?>? rateLimiter,
    bool? showErrorToast,
  }) =>
      _internalApiWrap<T, D>(
        function,
        onSuccess: onSuccess,
        onError: onError,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        showErrorToast: showErrorToast,
        shouldThrowOnError: false,
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
    RateLimiter<D>? rateLimiter,
    bool? showErrorToast,
  }) async =>
      (await _internalApiWrap<T, D>(
        function,
        onSuccess: onSuccess,
        onError: onError,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        showErrorToast: showErrorToast,
        shouldThrowOnError: true,
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
    RateLimiter<T?>? rateLimiter,
    bool? showErrorToast,
  }) =>
      _internalApiWrap<T, T>(
        function,
        onSuccess: onSuccess,
        onError: onError,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        showErrorToast: showErrorToast,
        shouldThrowOnError: false,
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
    RateLimiter<T>? rateLimiter,
    bool? showErrorToast,
  }) async =>
      (await _internalApiWrap<T, T>(
        function,
        onSuccess: onSuccess,
        onError: onError,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        showErrorToast: showErrorToast,
        shouldThrowOnError: true,
      )) as T;

  Future<D?> _internalApiWrap<T, D>(
    FutureOr<T> Function() function, {
    required FutureOr<D?> Function(T res)? onSuccess,
    required FutureOr<D?> Function(ApiError<ErrorType> error)? onError,
    required Duration? delay,
    required Retry<ErrorType>? retry,
    required RateLimiter<D?>? rateLimiter,
    required bool? showErrorToast,
    required bool shouldThrowOnError,
  }) =>
      wrapController.internalApiWrap.execute<T, D>(
        function,
        onSuccess: onSuccess,
        onError: (error) => wrapController.onError?.call(
          error: error,
          showErrorToast:
              showErrorToast ?? wrapController.defaultShowErrorToast,
          originalOnError: onError,
        ),
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        shouldThrowOnError: shouldThrowOnError,
      );
}
