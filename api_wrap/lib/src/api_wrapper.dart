part of 'api_wrap.dart';

abstract class IApiWrap<ErrorType> {
  FutureOr<void> onError(ApiError<ErrorType> error);

  @protected
  abstract final ApiWrapController<ErrorType> wrapController;
}

/// Тип колбека, используемый для обработки ошибок API.
typedef OnError<ErrorType, Result> = FutureOr<Result> Function(
    ApiError<ErrorType> error);
// Колбэк, задаваемый в контроллере, который по умолчанию обрабатывает все ошибки.
typedef GlobalOnError<ErrorType> = FutureOr<void> Function(
    ApiError<ErrorType> error);

/// {@template [ApiWrapper]}
/// Предоставляет утилиты и обёртки для [Dio] запросов и обычных функций.
///
/// Даёт возможность реализовать автоматическую обработку ошибок (логгирование и показ тостов) с возможность отлючения.
/// Предоставляет методы для обработки успешного и ошибочного ответа API.
/// {@endtemplate}
class ApiWrapper<ErrorType> implements IApiWrap<ErrorType> {
  /// {@macro [ApiWrapper]}
  ApiWrapper({
    required GlobalOnError<ErrorType> onError,
    ApiWrapController<ErrorType>? options,
  })  : _onError = onError,
        wrapController = options ?? ApiWrapController<ErrorType>();

  @override
  @protected
  final ApiWrapController<ErrorType> wrapController;

  final GlobalOnError<ErrorType> _onError;

  @override
  FutureOr<void> onError(ApiError<ErrorType> error) => _onError(error);
}
