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
  });

  final RateLimiter rateLimiter;
  DateTime? _startAt;

  RateTimings calculateRateTimings({
    Duration? elapsedTime,
  }) {
    elapsedTime = elapsedTime ??
        (_startAt != null
            ? DateTime.now().difference(_startAt!)
            : Duration.zero);
    return RateTimings(rateLimiter.duration, elapsedTime);
  }
}

class DebounceOperation<T> extends RateOperation<T> {
  DebounceOperation({
    required super.rateLimiter,
    required this.timer,
    required this.completer,
    required this.function,
    required this.onDelayEnd,
  }) {
    _startAt = DateTime.now();
  }

  final Timer timer;
  final Completer<RateOperationResult<T>> completer;
  final FutureOr<T> Function() function;
  final void Function() onDelayEnd;

  void cancel({
    required String tag,
  }) {
    timer.cancel();
    onDelayEnd();

    if (completer.isCompleted) return;
    completer.complete(
      RateOperationCancel<T>(
        rateLimiter: 'Debounce',
        tag: tag,
        timings: calculateRateTimings(),
      ),
    );
  }

  Future<void> complete() async {
    timer.cancel();
    onDelayEnd();

    try {
      final res = await function.call();
      if (completer.isCompleted) return;
      completer.complete(RateOperationSuccess(res));
    } catch (e, s) {
      if (completer.isCompleted) return;
      completer.completeError(e, s);
    }
  }
}

class ThrottleOperation<T> extends RateOperation<T> {
  ThrottleOperation({
    required super.rateLimiter,
    required this.onCooldownEnd,
  });

  final void Function() onCooldownEnd;
  bool cooldownIsCancel = false;
  late Timer _timer;

  void startCooldown({
    required Duration duration,
  }) {
    _startAt = DateTime.now();
    _timer = Timer(duration, cancelCooldown);
  }

  void cancelCooldown() {
    cooldownIsCancel = true;
    _timer.cancel();
    onCooldownEnd();
  }
}
