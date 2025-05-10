import 'dart:async';

import '../rate_limiter.dart';
import '../core/rate_operation.dart';
import '../core/rate_timings.dart';
import '../../operations_container.dart';

/// Options for when to start the cooldown period
enum CooldownLaunch {
  /// Cooldown starts immediately when the function execution begins
  immediately,

  /// Cooldown starts after the function execution completes
  afterFunction,
}

/// Rate limiter that limits execution frequency, ensuring a minimum
/// interval between function calls
class Throttle extends RateLimiter {
  /// Creates a throttle rate limiter.
  ///
  /// Immediately executes the function. If the method is called again with the
  /// same [key] within the specified time, the new request will not be executed.
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

  /// Processes a function with throttle rate limiting
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

/// Represents a throttled operation
class ThrottleOperation<T> extends RateOperation<T> {
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

  /// Starts the cooldown period
  void startCooldown({
    required Duration duration,
  }) {
    startAt = DateTime.now();
    _timer = Timer(duration, cancelCooldown);
  }

  /// Cancels the cooldown period
  void cancelCooldown() {
    cooldownIsCancel = true;
    _timer.cancel();
    onCooldownEnd();
  }
}
