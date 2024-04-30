part of 'api_wrap.dart';

sealed class RateOperationResult<T> {
  const RateOperationResult();
}

class RateOperationSuccess<T> extends RateOperationResult<T> {
  const RateOperationSuccess(this.data);
  final T data;
}

class RateOperationCancel<T> implements RateOperationResult<T> {
  RateOperationCancel({
    required this.rateLimiter,
    required this.tag,
    required this.timings,
  });

  final String rateLimiter;
  final String tag;
  final RateTimings timings;
}

class RateOperationsContainer {
  RateOperationsContainer();

  final Map<String, DebounceOperation> debounceOperations = {};
  final Map<String, ThrottleOperation> throttleOperations = {};
}

sealed class RateOperation<T> {
  RateOperation({
    required this.rateLimiter,
  }) {
    _startAt = DateTime.now();
  }

  final RateLimiter rateLimiter;
  late DateTime _startAt;

  RateTimings calculateRateTimings({
    Duration? elapsedTime,
  }) {
    elapsedTime = elapsedTime ?? DateTime.now().difference(_startAt);
    return RateTimings(rateLimiter.duration, elapsedTime);
  }
}

class DebounceOperation<T> extends RateOperation<T> {
  DebounceOperation({
    required this.timer,
    required this.completer,
    required this.function,
    required super.rateLimiter,
  });

  final Timer timer;
  final Completer<RateOperationResult<T>> completer;
  final FutureOr<T> Function() function;

  void cancel({
    required RateOperationCancel<T> rateCancel,
  }) {
    timer.cancel();
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

class ThrottleOperation<T> extends RateOperation<T> {
  ThrottleOperation({
    required super.rateLimiter,
    required this.onCooldownEnd,
  }) {
    _startAt = DateTime.now();
  }

  final VoidCallback onCooldownEnd;
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
    onCooldownEnd();
  }
}
