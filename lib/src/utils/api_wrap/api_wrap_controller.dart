part of 'api_wrap.dart';

class ApiWrapController<ErrorType> {
  ApiWrapController({
    this.retry,
    this.parseError,
    this.onError,
    this.defaultShowErrorToast = true,
  }) {
    container = RateOperationsContainer();
    internalApiWrap = InternalApiWrap<ErrorType>(
      retry: retry ?? Retry(maxAttempts: 0),
      parseError: parseError,
      container: container,
    );
  }

  final Retry? retry;
  final ErrorType Function(Object)? parseError;
  final ErrorResponseOnError<ErrorType>? onError;
  final bool defaultShowErrorToast;

  late final RateOperationsContainer container;
  late final InternalApiWrap<ErrorType> internalApiWrap;

  Future<void> fireDebounceOperation(String tag) async {
    await container.debounceOperations.remove(tag)?.complete();
  }

  Future<void> fireAllDebounceOperations() async {
    final futures = <Future<void>>[];
    for (final tag in container.debounceOperations.keys) {
      futures.add(container.debounceOperations.remove(tag)!.complete());
    }

    await futures.wait;
  }

  void cancelDebounceOperation(String tag) {
    container.debounceOperations.remove(tag)?.cancel();
  }

  void cancelThrottleCooldown(String tag) {
    container.throttleOperations.remove(tag)?.cancelCooldown();
  }

  void cancelAllOperations() {
    for (final operation in container.debounceOperations.values) {
      operation.cancel();
    }

    for (final operation in container.throttleOperations.values) {
      operation.cancelCooldown();
    }
  }
}
