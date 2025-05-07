/// Метод может выбросить исключения и должен быть обработан в одном из handle методов.
const shouldHandle = _ShoudleHandle();

class _ShoudleHandle {
  const _ShoudleHandle();
}

// Probably an error when casting res.data to ErrorType when the error type is set and _parseError is not present
class ParseBaseResponseErrorMissingError extends ArgumentError {
  @override
  String get message => 'If ErrorType is specified, the parseError parameter must be passed to the ApiWrapController.';
}
