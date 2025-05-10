import 'dart:async';

import 'handled_error.dart';

/// Метод может выбросить исключения и должен быть обработан в одном из handle методов.
const shouldHandle = _ShoudleHandle();

class _ShoudleHandle {
  const _ShoudleHandle();
}

/// Парсер ошибок для приведения к типу BaseResponseError.
typedef ParseBaseResponseError<BaseResponseError> = BaseResponseError Function(
    dynamic data);

/// Функция для обработки ошибок при запросе к API.
typedef OnError<BaseResponseError, D> = FutureOr<D> Function(
    HandledError<BaseResponseError> error);

/// Глобальный обработчик ошибок для всего Handler.
typedef GlobalOnError<BaseResponseError> = FutureOr<void> Function(
    HandledError<BaseResponseError> error);

/// Предоставляет расширение Future метода для ожидания группы Future.
extension WaitBoth<T extends Object?> on List<Future<T>> {
  /// Ждет завершения всех Future из списка и возвращает результаты
  /// в виде списка без сохранения порядка завершения.
  Future<List<T>> get wait => Future.wait<T>(this);
}

/// Исключение, которое выбрасывается, когда не задана функция parseBaseResponseError,
/// хотя BaseResponseError не является динамическим.
class ParseBaseResponseErrorMissingError extends Error {
  @override
  String toString() =>
      'If ErrorType is specified, the parseError parameter must be passed to the Handler';
}

typedef WrapError<BaseResponseError> = HandledError<BaseResponseError> Function(
    Object e, StackTrace s);
