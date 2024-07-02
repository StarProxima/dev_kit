import 'dart:developer';

import 'package:api_wrap/api_wrap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

final apiWrapper = ApiWrapper(
  onError: onError,
);

typedef BaseApiError = dynamic;

/// Метод для обработки ошибок API c логгированием и показом тостов при необходимости.
void onError(
  ApiError<BaseApiError> error, {
  bool showToast = true,
  bool isDebug = false,
  bool shouldReport = true,
}) {
  void showError(ApiError<BaseApiError> error) {
    // You can use any other package or custom solution for display errors
    toastification.show(
      type: ToastificationType.error,
      title: Text(switch (error) {
        ErrorResponse() => 'Backend Error',
        InternalError() => 'Internal Error',
        RateCancelError() => 'RateLimiterError',
      }),
      description: Text(error.toShortString()),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  if (showToast) {
    switch (error) {
      case InternalError<BaseApiError>() ||
            ErrorResponse<BaseApiError>(
              statusCode: 401,
            ):
        if (kDebugMode) {
          showError(error);
        }

      case ErrorResponse<BaseApiError>():
        showError(error);
      case RateCancelError():
        break;
    }
  }

  if (shouldReport) {
    switch (error) {
      case InternalError<BaseApiError>(
              :final stackTrace,
            ) ||
            ErrorResponse<BaseApiError>(:final stackTrace):

        // Send to your crashlytics or other service
        log('Report', stackTrace: stackTrace);

      case RateCancelError():
        break;
    }
  }

  if (error is InternalError<BaseApiError>) {
    // Use your logger
    log(error.toString());
  }
}
