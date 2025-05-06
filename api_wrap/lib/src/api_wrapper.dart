part of 'api_wrap.dart';

abstract class IApiWrap<BaseResponseError> {
  FutureOr<void> onError(HandledError<BaseResponseError> error);

  @protected
  abstract final ApiWrapController<BaseResponseError> wrapController;
}

/// Тип колбека, используемый для обработки ошибок API.
typedef OnError<BaseResponseError, Result> = FutureOr<Result> Function(HandledError<BaseResponseError> error);
// Колбэк, задаваемый в контроллере, который по умолчанию обрабатывает все ошибки.
typedef GlobalOnError<BaseResponseError> = FutureOr<void> Function(HandledError<BaseResponseError> error);

/// {@template [ApiWrapper]}
/// Предоставляет утилиты и обёртки для [Dio] запросов и обычных функций.
///
/// Даёт возможность реализовать автоматическую обработку ошибок (логгирование и показ тостов) с возможность отлючения.
/// Предоставляет методы для обработки успешного и ошибочного ответа API.
/// {@endtemplate}
class ApiWrapper<BaseResponseError> implements IApiWrap<BaseResponseError> {
  /// {@macro [ApiWrapper]}
  ApiWrapper({
    required GlobalOnError<BaseResponseError> onError,
    ApiWrapController<BaseResponseError>? options,
  })  : _onError = onError,
        wrapController = options ?? ApiWrapController<BaseResponseError>();

  @override
  @protected
  final ApiWrapController<BaseResponseError> wrapController;

  final GlobalOnError<BaseResponseError> _onError;

  @override
  FutureOr<void> onError(HandledError<BaseResponseError> error) => _onError(error);
}
