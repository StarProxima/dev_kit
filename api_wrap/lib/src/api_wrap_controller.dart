part of 'api_wrap.dart';

class ApiWrapController<BaseHttpErrorType> {
  ApiWrapController({
    this.retry,
    this.parseError,
  }) {
    if (parseError == null) {
      if (BaseHttpErrorType.toString() case 'dynamic' || 'Object?') {
      } else {
        throw ParseErrorMissingError();
      }
    }

    container = RateOperationsContainer();
    internalApiWrap = InternalApiWrap(
      retry: retry ?? Retry.none(),
      parseError: parseError,
      container: container,
    );
  }

  final Retry? retry;
  final ParseError<BaseHttpErrorType>? parseError;

  late final RateOperationsContainer container;
  late final InternalApiWrap<BaseHttpErrorType> internalApiWrap;

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
    for (final MapEntry(key: tag, value: operation) in container.debounceOperations.entries) {
      operation.cancel(tag: tag);
    }

    for (final operation in container.throttleOperations.values) {
      operation.cancelCooldown();
    }
  }
}
