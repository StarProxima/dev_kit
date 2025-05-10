import 'dart:async';

import 'handled_error.dart';

/// Annotation indicating a method may throw exceptions
/// and should be handled in one of the Handler's handle methods.
const shouldHandle = _ShoudleHandle();

class _ShoudleHandle {
  const _ShoudleHandle();
}

/// Function for parsing raw error responses into the application-specific
/// BaseResponseError type.
///
/// Takes raw API error data and converts it to the strongly-typed BaseResponseError.
typedef ParseBaseResponseError<BaseResponseError> = BaseResponseError Function(
    dynamic data);

/// Function for handling errors encountered during API requests.
///
/// Called when an error occurs, allowing for custom error processing and recovery.
/// Returns a value of type D, which can be used as fallback data.
typedef OnError<BaseResponseError, D> = FutureOr<D> Function(
    HandledError<BaseResponseError> error);

/// Global error handler for the entire Handler instance.
///
/// Called for every error encountered, allowing for centralized logging,
/// monitoring, or other error processing that doesn't affect the request flow.
typedef GlobalOnError<BaseResponseError> = FutureOr<void> Function(
    HandledError<BaseResponseError> error);

/// Function for wrapping raw errors into HandledError types.
///
/// Takes an exception and stack trace and produces a properly typed
/// HandledError for consistent error handling.
typedef WrapError<BaseResponseError> = HandledError<BaseResponseError> Function(
    Object e, StackTrace s);
