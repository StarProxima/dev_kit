part of 'api_wrap.dart';

sealed class RateResult<T> {
  const RateResult();
}

class RateSuccess<T> extends RateResult<T> {
  const RateSuccess(this.data);
  final T data;
}

class RateCancel<T> extends RateResult<T> {}

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
  final Completer<RateResult<T>> completer;
  final FutureOr<T> Function() function;
  final RateLimiter rateLimiter;

  void cancel() {
    timer.cancel();
    rateLimiter.onCancelOperation?.call();
    if (completer.isCompleted) return;
    completer.complete(RateCancel());
  }

  Future<void> complete() async {
    timer.cancel();
    try {
      final res = await function.call();
      if (completer.isCompleted) return;
      completer.complete(RateSuccess(res));
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
