part of 'api_wrap.dart';

/// Метод может выбросить исключения и должен быть обработан в одном из apiWrap методов.
const useInApiWrap = _UseInApiWrap();

class _UseInApiWrap {
  const _UseInApiWrap();
}

// Probably an error when casting res.data to ErrorType when the error type is set and _parseError is not present
class ParseErrorMissingError extends ArgumentError {
  @override
  get message =>
      'If ErrorType is specified, the parseError parameter must be passed to the ApiWrapController.';
}
