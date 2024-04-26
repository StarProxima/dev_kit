part of 'api_wrap.dart';

class ApiWrapController<ErrorType> {
  ApiWrapController({
    this.retry,
    this.parseError,
    this.onError,
    this.defaultShowErrorToast = true,
  }) {
    container = RateOperationsContainer();
    internalApiWrap = InternalApiWrap(
      retry: retry ?? Retry(maxAttempts: 0),
      parseError: parseError,
      container: container,
    );
  }

  final Retry<ErrorType>? retry;
  final ErrorType Function(Object)? parseError;
  final ErrorResponseOnError<ErrorType>? onError;
  final bool defaultShowErrorToast;

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
    container.debounceOperations.remove(tag)?.cancel(
          rateCancel: RateOperationCancel(rateLimiter: 'Debounce', tag: tag),
        );
  }

  void cancelThrottleCooldown(String tag) {
    container.throttleOperations.remove(tag)?.cancelCooldown();
  }

  void cancelAllOperations() {
    for (final MapEntry(key: tag, value: operation)
        in container.debounceOperations.entries) {
      operation.cancel(
        rateCancel: RateOperationCancel(rateLimiter: 'Debounce', tag: tag),
      );
    }

    for (final operation in container.throttleOperations.values) {
      operation.cancelCooldown();
    }
  }
}
