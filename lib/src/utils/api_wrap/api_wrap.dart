import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core_dev_kit.dart';

enum ErrorVisibility {
  /// Отображать ошибку всегда.
  always,

  /// Отображать ошибку только для отладки.
  debugOnly,

  /// Не отображать ошибку.
  never,
}

/// {@template [ApiWrapper]}
/// Предоставляет утилиты и обёртки для [Dio] запросов и обычных функций.
///
/// Даёт возможность реализовать автоматическую обработку ошибок (логгирование и показ тостов) с возможность отлючения.
/// Предоставляет методы для обработки успешного и ошибочного ответа API.
/// {@endtemplate}
class ApiWrapper implements IApiWrap {
  /// {@macro [ApiWrapper]}
  ApiWrapper({
    ApiWrapOptions? opstions,
  }) : wrapOptions = opstions ??
            ApiWrapOptions(
              parseError: (e) => e,
            );

  @override
  final ApiWrapOptions wrapOptions;

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
  required ErrorResponse<ErrorType> error,
  required ErrorVisibility errorVisibility,
  required FutureOr<D?> Function(ErrorResponse<ErrorType> error)?
      originalOnError,
});

class ApiWrapOptions<ErrorType> {
  ApiWrapOptions({
    Retry? retry,
    required ErrorType Function(Object) parseError,
    this.onError,
  }) : internalApiWrap = InternalApiWrap(
          retry: retry ?? Retry(maxAttempts: 0),
          parseError: parseError,
        );

  final InternalApiWrap<ErrorType> internalApiWrap;
  final ErrorResponseOnError<ErrorType>? onError;
}

abstract class IApiWrap<ErrorType> {
  @protected
  abstract final ApiWrapOptions<ErrorType> wrapOptions;
}

extension ApiWrapX<ErrorType> on IApiWrap<ErrorType> {
  /// Обёртывает [Dio] запрос к API или обычную функцию с возможностью использования
  /// последовательных вложенных запросов, автоматической/ручной обработки ошибок и доп. логики.
  ///
  /// [function] - [Dio] запрос или функция.
  ///
  /// [onSuccess] - функция, которая будет вызвана при успешном ответе API.
  ///
  /// [onError] - функция, которая будет вызвана при ошибке API.
  ///
  /// [delay] - задержка перед выполнением запроса.
  ///
  /// [retry] - настройки повторных попыток выполнения запроса.
  /// Если не указано, то повторных попыток не будет.
  ///
  /// ```dart
  /// await apiWrap(
  ///   () => api.login(),
  ///   onSuccess: (token) => appStorage.updateToken(token),
  ///   onError: (_) => appStorage.clearToken(),
  /// );
  /// ```
  Future<D?> apiWrap<T, D>(
    FutureOr<T> Function() function, {
    FutureOr<D?> Function(T)? onSuccess,
    FutureOr<D?> Function(ErrorResponse<ErrorType> error)? onError,
    ErrorVisibility errorVisibility = ErrorVisibility.always,
    Duration? delay,
    ExecuteIf? executeIf,
    RateLimiter? rateLimiter,
    Retry? retry,
  }) =>
      wrapOptions.internalApiWrap<T, D>(
        function,
        onSuccess: onSuccess,
        onError: (error) => wrapOptions.onError?.call(
          error: error,
          errorVisibility: errorVisibility,
          originalOnError: onError,
        ),
        delay: delay,
        executeIf: executeIf,
        rateLimiter: rateLimiter,
        retry: retry,
      );

  void test() {
    apiWrap(
      () => null,
      errorVisibility: ErrorVisibility.always,
    );
  }

  /// Как [apiWrap], но требует указывать все колбеки, что позволяет возвращать ненулевое значение.
  ///
  /// Пример:
  /// ```dart
  /// final userIsAuthorized = await apiWrapGuard(
  ///   () => api.auth(login: 'user', password: '123'),
  ///   onSuccess: (user) {
  ///     saveUser(user);
  ///     return true;
  ///   },
  ///   onError: (_) => false,
  /// );
  /// ```
  Future<D> apiWrapGuard<T, D>(
    FutureOr<T> Function() function, {
    required FutureOr<D> Function(T) onSuccess,
    required FutureOr<D> Function(ErrorResponse<ErrorType> error) onError,
    ErrorVisibility errorVisibility = ErrorVisibility.always,
    Duration? delay,
    Retry? retry,
  }) async =>
      (await apiWrap<T, D>(
        function,
        onSuccess: onSuccess,
        onError: onError,
        delay: delay,
        retry: retry,
        errorVisibility: errorVisibility,
      )) as D;

  /// Как [apiWrap], возвращает тот же тип, что и [function], но может быть null при ошибке.
  ///
  /// Пример:
  /// ```dart
  /// final user = await apiWrapSingle(api.getCurrentUser);
  /// if(user != null) ...
  /// ```
  Future<T?> apiWrapSingle<T>(
    FutureOr<T> Function() function, {
    FutureOr<T?> Function(T)? onSuccess,
    FutureOr<T?> Function(ErrorResponse<ErrorType> error)? onError,
    ErrorVisibility errorVisibility = ErrorVisibility.always,
    Duration? delay,
    ExecuteIf? executeIf,
    RateLimiter? rateLimiter,
    Retry? retry,
  }) =>
      apiWrap(
        function,
        onSuccess: onSuccess,
        onError: onError,
        delay: delay,
        executeIf: executeIf,
        rateLimiter: rateLimiter,
        retry: retry,
        errorVisibility: errorVisibility,
      );

  /// Объединяет свойства [apiWrapGuard] и [apiWrapSingle].
  ///
  /// Требует обязательных колбеков для обработки ошибок.
  /// Возвращает тот же ненулевой тип, что и [function].
  /// Если [onSuccess] не указан, то метод возвращает результат [function].
  ///
  /// Пример:
  /// ```dart
  /// // user не может быть null
  /// final user = await apiWrapSingleGuard(
  ///   api.getCurrentUser,
  ///   onError: (_) => User.empty(),
  /// );
  /// ```
  Future<T> apiWrapSingleGuard<T>(
    FutureOr<T> Function() function, {
    FutureOr<T> Function(T)? onSuccess,
    required FutureOr<T> Function(ErrorResponse<ErrorType> error) onError,
    ErrorVisibility errorVisibility = ErrorVisibility.always,
    Duration? delay,
    Retry? retry,
  }) async =>
      (await apiWrap<T, T>(
        function,
        onSuccess: onSuccess,
        onError: onError,
        delay: delay,
        retry: retry,
        errorVisibility: errorVisibility,
      ))!;
}
