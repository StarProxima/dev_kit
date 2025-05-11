import 'dart:async';

import '../rate_limiter.dart';
import '../core/rate_operation.dart';
import '../core/rate_timings.dart';
import '../../operations_container.dart';

/// {@template cooldown_launch}
/// Options for when to start the cooldown period in throttle operations.
/// {@endtemplate}
enum CooldownLaunch {
  /// Cooldown starts immediately when the function execution begins
  immediately,

  /// Cooldown starts after the function execution completes
  afterFunction,
}

/// {@template throttle_rate_limiter}
/// Rate limiter that limits execution frequency, ensuring a minimum
/// interval between function calls.
///
/// Throttle immediately executes the first function call, then rejects
/// subsequent calls until the cooldown period has elapsed.
/// {@endtemplate}
class Throttle extends RateLimiter {
  /// {@macro throttle_rate_limiter}
  ///
  /// Immediately executes the function. If the method is called again with the
  /// same [key] within the specified time, the new request will not be executed.
  ///
  /// [duration] - The minimum interval between function executions.
  /// [cooldownLaunch] - When to start the cooldown period.
  /// [tickInterval] - Interval for timing updates during cooldown.
  /// [onCooldownStart] - Callback triggered when cooldown starts.
  /// [onCooldownTick] - Callback triggered on each tick during cooldown.
  /// [onCooldownEnd] - Callback triggered when cooldown ends.
  Throttle({
    super.duration,
    this.cooldownLaunch = CooldownLaunch.afterFunction,
    this.tickInterval = const Duration(seconds: 1),
    this.onCooldownStart,
    this.onCooldownTick,
    this.onCooldownEnd,
  });

  /// When to start the cooldown period
  final CooldownLaunch cooldownLaunch;

  /// Interval for timing update ticks
  final Duration tickInterval;

  /// Callback triggered when cooldown starts
  final void Function()? onCooldownStart;

  /// Callback triggered on each tick during cooldown with timing information
  final void Function(RateTimings timings)? onCooldownTick;

  /// Callback triggered when cooldown ends
  final void Function()? onCooldownEnd;

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
    final operations = (container ?? this.container).throttleOperations;
    final existingOperation = operations[key];

    if (existingOperation != null) {
      return RateOperationCancel<D>(
        key: key,
        timings: existingOperation.calculateRateTimings(),
      );
    }

    Timer? cooldownTickTimer;

    final operation = ThrottleOperation<D>(
      rateLimiter: this,
      onCooldownEnd: () {
        final operation = operations.remove(key);
        cooldownTickTimer?.cancel();

        if (operation == null) return;

        onCooldownTick?.call(
          operation.calculateRateTimings(
            elapsedTime: operation.rateLimiter.duration,
          ),
        );
        onCooldownEnd?.call();
      },
    );
    operations[key] = operation;

    final FutureOr<D> futureOr;

    try {
      futureOr = cooldownLaunch == CooldownLaunch.afterFunction
          ? await function()
          : function();
    } catch (_) {
      rethrow;
    } finally {
      if (!operation.cooldownIsCancel) {
        operation.startCooldown(duration: duration);

        onCooldownStart?.call();

        final onTick = onCooldownTick;

        if (onTick != null) {
          final timings = RateTimings(
            duration: duration,
            elapsedTime: Duration.zero,
            remainingTime: null,
          );

          onTick(timings);
          cooldownTickTimer = Timer.periodic(
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
      }
    }

    final data = await futureOr;
    return RateOperationSuccess(data);
  }
}

/// {@template throttle_operation}
/// Represents a throttled operation with its state and control mechanisms.
///
/// Manages the lifecycle of a function execution that has been throttled,
/// including timing, cooldown period, and cancellation.
/// {@endtemplate}
class ThrottleOperation<T> extends RateOperation<T> {
  /// {@macro throttle_operation}
  ///
  /// [rateLimiter] - The rate limiter that created this operation.
  /// [onCooldownEnd] - Callback when cooldown period ends.
  ThrottleOperation({
    required super.rateLimiter,
    required this.onCooldownEnd,
  });

  /// Callback when cooldown period ends
  final void Function() onCooldownEnd;

  /// Whether the cooldown has been canceled
  bool cooldownIsCancel = false;

  /// Timer controlling the cooldown period
  late Timer _timer;

  /// Starts the cooldown period with the specified duration
  ///
  /// [duration] - The duration of the cooldown period.
  void startCooldown({
    required Duration duration,
  }) {
    startAt = DateTime.now();
    _timer = Timer(duration, cancelCooldown);
  }

  /// Cancels the cooldown period, stopping the timer and notifying subscribers
  void cancelCooldown() {
    cooldownIsCancel = true;
    _timer.cancel();
    onCooldownEnd();
  }
}
