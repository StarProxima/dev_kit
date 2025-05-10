import 'dart:async';

import '../rate_limiter.dart';
import '../core/rate_operation.dart';
import '../core/rate_timings.dart';
import '../../operations_container.dart';

/// {@template debounce_rate_limiter}
/// Rate limiter that delays function execution until specified time has passed
/// since the last call.
///
/// When multiple calls are made in quick succession, only the last one will
/// execute after the specified delay period has elapsed since the most recent call.
/// {@endtemplate}
class Debounce extends RateLimiter {
  /// {@macro debounce_rate_limiter}
  ///
  /// If the method is called again with the same [key],
  /// the previous request will be canceled, and the new one will execute after the specified time.
  ///
  /// [duration] - The delay before executing the function.
  /// [canCancelRunningFunction] - Whether running functions can be canceled when a new call is made.
  /// [tickInterval] - Interval for timing update ticks during delay.
  /// [onDelayStart] - Callback triggered when delay starts.
  /// [onDelayTick] - Callback triggered on each tick during delay with timing information.
  /// [onDelayEnd] - Callback triggered when delay ends.
  Debounce({
    super.duration,
    this.canCancelRunningFunction = true,
    this.tickInterval = const Duration(seconds: 1),
    this.onDelayStart,
    this.onDelayTick,
    this.onDelayEnd,
  });

  /// Whether running functions can be canceled when a new call is made
  final bool canCancelRunningFunction;

  /// Interval for timing update ticks
  final Duration tickInterval;

  /// Callback triggered when delay starts
  final void Function()? onDelayStart;

  /// Callback triggered on each tick during delay with timing information
  final void Function(RateTimings timings)? onDelayTick;

  /// Callback triggered when delay ends
  final void Function()? onDelayEnd;

  /// Container for operations managed by this rate limiter
  final container = OperationsContainer();

  /// {@macro rate_limiter.process}
  ///
  /// [key] - Identifier for the request. If not specified, [StackTrace.current] is used.
  @override
  Future<RateOperationResult<D>> process<D>(
    FutureOr<D> Function() function, {
    Object? key,
    OperationsContainer? container,
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

/// {@template debounce_operation}
/// Represents a debounced operation with its state and control mechanisms.
///
/// Manages the lifecycle of a function execution that has been debounced,
/// including timing, cancellation, and completion.
/// {@endtemplate}
class DebounceOperation<T> extends RateOperation<T> {
  /// {@macro debounce_operation}
  ///
  /// [rateLimiter] - The rate limiter that created this operation.
  /// [key] - Unique key identifying this operation.
  /// [timer] - Timer controlling the delay.
  /// [completer] - Completer for the operation result.
  /// [function] - Function to execute after delay.
  /// [onDelayEnd] - Callback when delay ends.
  DebounceOperation({
    required super.rateLimiter,
    required this.key,
    required this.timer,
    required this.completer,
    required this.function,
    required this.onDelayEnd,
  });

  /// Unique key identifying this operation
  final Object key;

  /// Timer controlling the delay
  final Timer timer;

  /// Completer for the operation result
  final Completer<RateOperationResult<T>> completer;

  /// Function to execute after delay
  final FutureOr<T> Function() function;

  /// Callback when delay ends
  final void Function() onDelayEnd;

  /// Starts the operation by recording start time
  void start() {
    startAt = DateTime.now();
  }

  /// Cancels the operation, stopping the timer and notifying subscribers
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

  /// Completes the operation by executing the function and delivering the result
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
