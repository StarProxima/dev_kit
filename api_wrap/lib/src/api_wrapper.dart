part of 'api_wrap.dart';

abstract class IApiWrap<BaseHttpErrorType> {
  FutureOr<void> onError(ApiError<BaseHttpErrorType> error);

  @protected
  abstract final ApiWrapController<BaseHttpErrorType> wrapController;
}

/// Тип колбека, используемый для обработки ошибок API.
typedef OnError<BaseHttpErrorType, Result> = FutureOr<Result> Function(ApiError<BaseHttpErrorType> error);
// Колбэк, задаваемый в контроллере, который по умолчанию обрабатывает все ошибки.
typedef GlobalOnError<BaseHttpErrorType> = FutureOr<void> Function(ApiError<BaseHttpErrorType> error);

/// {@template [ApiWrapper]}
/// Предоставляет утилиты и обёртки для [Dio] запросов и обычных функций.
///
/// Даёт возможность реализовать автоматическую обработку ошибок (логгирование и показ тостов) с возможность отлючения.
/// Предоставляет методы для обработки успешного и ошибочного ответа API.
/// {@endtemplate}
class ApiWrapper<BaseHttpErrorType> implements IApiWrap<BaseHttpErrorType> {
  /// {@macro [ApiWrapper]}
  ApiWrapper({
    required GlobalOnError<BaseHttpErrorType> onError,
    ApiWrapController<BaseHttpErrorType>? options,
  })  : _onError = onError,
        wrapController = options ?? ApiWrapController<BaseHttpErrorType>();

  @override
  @protected
  final ApiWrapController<BaseHttpErrorType> wrapController;

  final GlobalOnError<BaseHttpErrorType> _onError;

  @override
  FutureOr<void> onError(ApiError<BaseHttpErrorType> error) => _onError(error);
}
