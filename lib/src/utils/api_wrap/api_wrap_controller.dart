part of 'api_wrap.dart';

class ApiWrapController<ErrorType> {
  ApiWrapController({
    this.retry,
    this.parseError,
    ErrorResponseOnError<ErrorType>? onError,
    this.defaultShowErrorToast = true,
  }) {
    this.onError = onError ?? _defaultOnError;
    container = RateOperationsContainer();
    internalApiWrap = InternalApiWrap(
      retry: retry ?? Retry(maxAttempts: 0),
      parseError: parseError,
      container: container,
    );
  }

  FutureOr<D?> _defaultOnError<D>({
    required ApiError<ErrorType> error,
    required bool showErrorToast,
    required FutureOr<D?> Function(ApiError<ErrorType> error)? originalOnError,
  }) {
    return originalOnError?.call(error);
  }

  final Retry<ErrorType>? retry;
  final ParseError<ErrorType>? parseError;
  final bool defaultShowErrorToast;
  late final ErrorResponseOnError<ErrorType> onError;

  late final RateOperationsContainer container;
  late final InternalApiWrap<ErrorType> internalApiWrap;

  Future<void> fireDebounceOperation(String tag) async {
    await container.debounceOperations.remove(tag)?.complete();
  }

  Future<void> fireAllDebounceOperations() async {
    final futures = [
      ...container.debounceOperations.values.map(
        (operation) => operation.complete(),
      ),
    ];

    container.debounceOperations.clear();

    await futures.wait;
  }

  void cancelDebounceOperation(String tag) {
    final operation = container.debounceOperations.remove(tag);
    operation?.cancel(tag: tag);
  }

  void cancelThrottleCooldown(String tag) {
    container.throttleOperations.remove(tag)?.cancelCooldown();
  }

  void cancelAllOperations() {
    for (final MapEntry(key: tag, value: operation)
        in container.debounceOperations.entries) {
      operation.cancel(tag: tag);
    }

    for (final operation in container.throttleOperations.values) {
      operation.cancelCooldown();
    }
  }
}
