part of 'api_wrap.dart';

sealed class RateOperationResult<T> {
  const RateOperationResult();
}

class RateOperationSuccess<T> extends RateOperationResult<T> {
  const RateOperationSuccess(this.data);
  final T data;
}

class RateOperationCancel<T> extends RateOperationResult<T>
    implements Exception {
  const RateOperationCancel({
    required this.rateLimiter,
    required this.tag,
  });

  final String rateLimiter;
  final String tag;

  @override
  String toString() =>
      'Operation was canceled by $rateLimiter. You can specify onCancelOperation in $rateLimiter to avoid throwing an exception. Operation tag:\n$tag';
}

class RateOperationsContainer {
  RateOperationsContainer();

  final Map<String, DebounceOperation> debounceOperations = {};
  final Map<String, ThrottleOperation> throttleOperations = {};
}

class DebounceOperation<T> {
  DebounceOperation({
    required this.timer,
    required this.completer,
    required this.function,
    required this.rateLimiter,
  });

  final Timer timer;
  final Completer<RateOperationResult<T>> completer;
  final FutureOr<T> Function() function;
  final RateLimiter rateLimiter;

  void cancel({
    required RateOperationCancel<T> rateCancel,
  }) {
    timer.cancel();
    rateLimiter.onCancelOperation?.call();
    if (completer.isCompleted) return;
    completer.complete(rateCancel);
  }

  Future<void> complete() async {
    timer.cancel();
    try {
      final res = await function.call();
      if (completer.isCompleted) return;
      completer.complete(RateOperationSuccess(res));
    } catch (e, s) {
      if (completer.isCompleted) return;
      completer.complete(Future.error(e, s));
    }
  }
}

class ThrottleOperation<T> {
  ThrottleOperation({
    required this.onCooldownEnd,
  });

  final VoidCallback onCooldownEnd;
  VoidCallback? cooldownCallback;
  bool cooldownIsCancel = false;
  late Timer _timer;

  void startCooldown({
    required Duration duration,
  }) {
    _timer = Timer(duration, cancelCooldown);
  }

  void cancelCooldown() {
    cooldownIsCancel = true;
    _timer.cancel();
    cooldownCallback?.call();
    onCooldownEnd();
  }
}
