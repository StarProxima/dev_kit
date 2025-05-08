import 'dart:async';

import '../rate_limiter.dart';
import '../core/rate_operation.dart';
import '../core/rate_timings.dart';

class Debounce extends RateLimiter {
  /// Задержит выполнение на заданное время.
  ///
  /// Если метод будет вызван ещё раз с тем же [tag],
  /// то предыдущий запрос будет отменён, а новый выполнится через заданное время.
  Debounce({
    super.duration,
    this.canCancelRunningFunction = true,
    this.tickInterval = const Duration(seconds: 1),
    this.onDelayStart,
    this.onDelayTick,
    this.onDelayEnd,
  });

  final bool canCancelRunningFunction;
  final Duration tickInterval;
  final void Function()? onDelayStart;
  final void Function(RateTimings timings)? onDelayTick;
  final void Function()? onDelayEnd;

  final container = RateOperationsContainer();

  /// [key] - тег для идентификации запроса, если не указан, то используется [StackTrace.current].
  @override
  Future<RateOperationResult<D>> process<D>(
    FutureOr<D> Function() function, {
    Object? key,
    RateOperationsContainer? container,
  }) async {
    key ??= '${StackTrace.current}';
    final operations = (container ?? this.container).debounceOperations;

    final completer = Completer<RateOperationResult<D>>();

    final existingOperation = operations[key];
    existingOperation?.cancel();

    Timer? delayTickTimer;

    final operation = DebounceOperation<D>(
      rateLimiter: this,
      key: key,
      timer: Timer(duration, () async {
        final operation = operations[key];
        final future = operation?.complete();
        try {
          if (canCancelRunningFunction) await future;
        } catch (_) {
          rethrow;
        } finally {
          if (operations.containsValue(operation)) operations.remove(key);
        }
      }),
      completer: completer,
      function: function,
      onDelayEnd: () {
        final operation = operations.remove(key);
        delayTickTimer?.cancel();

        final timings = operation!.calculateRateTimings(
          remainingTime: Duration.zero,
        );

        onDelayTick?.call(timings);
        onDelayEnd?.call();
      },
    );

    operation.start();

    operations[key] = operation;

    onDelayStart?.call();

    final onTick = onDelayTick;

    if (onTick != null) {
      final timings = RateTimings(
        duration: duration,
        elapsedTime: Duration.zero,
        remainingTime: null,
      );
      onTick(timings);

      delayTickTimer = Timer.periodic(
        tickInterval,
        (timer) {
          final timings = operation.calculateRateTimings(
            elapsedTime: Duration(
              milliseconds: timer.tick * tickInterval.inMilliseconds,
            ),
          );
          onTick(timings);
        },
      );
    }

    return completer.future;
  }
}

class DebounceOperation<T> extends RateOperation<T> {
  DebounceOperation({
    required super.rateLimiter,
    required this.key,
    required this.timer,
    required this.completer,
    required this.function,
    required this.onDelayEnd,
  });

  final Object key;
  final Timer timer;
  final Completer<RateOperationResult<T>> completer;
  final FutureOr<T> Function() function;
  final void Function() onDelayEnd;

  void start() {
    startAt = DateTime.now();
  }

  void cancel() {
    timer.cancel();
    onDelayEnd();

    if (completer.isCompleted) return;
    completer.complete(
      RateOperationCancel<T>(
        key: key,
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
