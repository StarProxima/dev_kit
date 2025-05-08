import 'dart:async';

import 'handled_error.dart';

/// Метод может выбросить исключения и должен быть обработан в одном из handle методов.
const shouldHandle = _ShoudleHandle();

class _ShoudleHandle {
  const _ShoudleHandle();
}

// Probably an error when casting res.data to ErrorType when the error type is set and _parseError is not present
class ParseBaseResponseErrorMissingError extends ArgumentError {
  @override
  String get message =>
      'If ErrorType is specified, the parseError parameter must be passed to the Handler.';
}

// Колбэк, задаваемый в контроллере, который по умолчанию обрабатывает все ошибки.
typedef GlobalOnError<BaseResponseError> = FutureOr<void> Function(
    HandledError<BaseResponseError> e);
typedef ParseBaseResponseError<BaseResponseError> = BaseResponseError Function(
    Object? e);

/// Тип колбека, используемый для обработки ошибок API.
typedef OnError<BaseResponseError, Result> = FutureOr<Result> Function(
    HandledError<BaseResponseError> e);

typedef WrapError<BaseResponseError> = HandledError<BaseResponseError> Function(
    Object e, StackTrace s);
