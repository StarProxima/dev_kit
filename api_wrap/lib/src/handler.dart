import 'dart:async';

import 'package:dio/dio.dart';

import 'handled_error.dart';
import 'handler_executor.dart';
import 'rate_limiter/rate_limiter.dart';
import 'rate_limiter/rate_operation.dart';
import 'retry/retry.dart';

/// Предоставляет утилиты и обёртки для [Dio] запросов и обычных функций.
///
/// Даёт возможность реализовать автоматическую обработку ошибок (логгирование и показ тостов) с возможность отлючения.
/// Предоставляет методы для обработки успешного и ошибочного ответа API.
class Handler<BaseResponseError> {
  Handler({
    required ParseBaseResponseError<BaseResponseError>? parseBaseResponseError,
    Retry? retry,
    RateOperationsContainer? container,
    GlobalOnError<BaseResponseError>? onError,
  })  : _parseBaseResponseError = parseBaseResponseError,
        _onError = onError,
        _container = container ?? RateOperationsContainer(),
        _executor = HandlerExecutor<BaseResponseError>();

  final ParseBaseResponseError<BaseResponseError>? _parseBaseResponseError;
  final HandlerExecutor<BaseResponseError> _executor;
  final GlobalOnError<BaseResponseError>? _onError;
  final RateOperationsContainer _container;

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
  FutureOr<D?> apiWrap<T, D>(
    FutureOr<T> Function() function, {
    Object? tag,
    Duration? delay,
    Duration? minExecutionTime,
    Retry? retry,
    RateLimiter? rateLimiter,
    FutureOr<D?> Function(T res)? onSuccess,
    OnError<BaseResponseError, D?>? onError,
  }) =>
      _executor.execute<T, D>(
        function: function,
        container: _container,
        wrapError: wrapError,
        tag: tag,
        minExecutionTime: minExecutionTime,
        delay: delay,
        retry: retry,
        rateLimiter: rateLimiter,
        onSuccess: onSuccess,
        onError: onError ??
            (e) {
              this.onError(e);
              return null;
            },
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
  }) async {
    final futureOr = _executor.execute<T, D>(
      function: function,
      container: _container,
      wrapError: wrapError,
      tag: tag,
      minExecutionTime: minExecutionTime,
      delay: delay,
      retry: retry,
      rateLimiter: rateLimiter,
      onSuccess: onSuccess,
      onError: onError ??
          (e) {
            this.onError(e);
            throw e;
          },
    );

    switch (futureOr) {
      case Future():
        return futureOr.then<D>((res) => res as D);

      case _:
        return futureOr as D;
    }
  }

  /// Преобразует исключение в специализированный [ApiError<ErrorType>].
  /// Обрабатывает различные типы ошибок, включая DioException.
  HandledError<BaseResponseError> wrapError(Object e, StackTrace s) {
    final apiError = switch (e) {
      HandledError<BaseResponseError>() => e,
      DioException(response: Response res) => ErrorResponse<BaseResponseError>(
          error: _parseBaseResponseError?.call(res.data) ?? res.data,
          stackTrace: s,
          dioException: e,
        ),
      _ => InternalError<BaseResponseError>(error: e, stackTrace: s),
    };

    return apiError;
  }

  FutureOr<void> onError(HandledError<BaseResponseError> error) => _onError?.call(error);

  Future<void> fireDebounceOperation(String tag) async {
    await _container.debounceOperations.remove(tag)?.complete();
  }

  Future<void> fireAllDebounceOperations() async {
    final futures = [
      ..._container.debounceOperations.values.map(
        (operation) => operation.complete(),
      ),
    ];

    _container.debounceOperations.clear();

    await futures.wait;
  }

  void cancelDebounceOperation(String tag) {
    final operation = _container.debounceOperations.remove(tag);
    operation?.cancel(tag: tag);
  }

  void cancelThrottleCooldown(String tag) {
    _container.throttleOperations.remove(tag)?.cancelCooldown();
  }

  void cancelAllOperations() {
    for (final MapEntry(key: tag, value: operation) in _container.debounceOperations.entries) {
      operation.cancel(tag: tag);
    }

    for (final operation in _container.throttleOperations.values) {
      operation.cancelCooldown();
    }
  }
}

// Колбэк, задаваемый в контроллере, который по умолчанию обрабатывает все ошибки.
typedef GlobalOnError<BaseResponseError> = FutureOr<void> Function(HandledError<BaseResponseError> e);
typedef ParseBaseResponseError<BaseResponseError> = BaseResponseError Function(Object? e);
