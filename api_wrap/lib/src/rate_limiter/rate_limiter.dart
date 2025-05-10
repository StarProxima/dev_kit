// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import '../operations_container.dart';
import 'core/rate_operation.dart';
import 'core/rate_timings.dart';

import 'limiters/debounce.dart';
import 'limiters/throttle.dart';

/// {@template rate_limiter}
/// Base class for rate limiters like [Debounce] and [Throttle].
///
/// Rate limiters control the execution frequency of operations, helping
/// to optimize performance and resource usage.
/// {@endtemplate}
abstract class RateLimiter {
  /// {@macro rate_limiter}
  ///
  /// [duration] - The duration to use for rate limiting (delay or cooldown period).
  RateLimiter({
    this.duration = Duration.zero,
  });

  /// {@template rate_limiter.debounce}
  /// Creates a debounce rate limiter.
  ///
  /// Debounce delays function execution until specified time has passed
  /// since the last call. This is useful for handling rapid sequential events
  /// where only the final state matters.
  /// {@endtemplate}
  ///
  /// [duration] - The delay before executing the function.
  /// [canCancelRunningOperations] - Whether running operations can be canceled.
  /// [tickInterval] - Interval for timing updates during delay.
  /// [onDelayStart] - Callback triggered when delay starts.
  /// [onDelayTick] - Callback triggered on each tick during delay.
  /// [onDelayEnd] - Callback triggered when delay ends.
  factory RateLimiter.debounce({
    Duration duration = Duration.zero,
    bool canCancelRunningOperations = true,
    Duration tickInterval = const Duration(seconds: 1),
    void Function()? onDelayStart,
    void Function(RateTimings timings)? onDelayTick,
    void Function()? onDelayEnd,
  }) =>
      Debounce(
        duration: duration,
        canCancelRunningFunction: canCancelRunningOperations,
        tickInterval: tickInterval,
        onDelayStart: onDelayStart,
        onDelayTick: onDelayTick,
        onDelayEnd: onDelayEnd,
      );

  /// {@template rate_limiter.throttle}
  /// Creates a throttle rate limiter.
  ///
  /// Throttle limits the execution frequency of a function,
  /// ensuring a minimum interval between executions. This prevents
  /// excessive function calls during high-frequency events.
  /// {@endtemplate}
  ///
  /// [duration] - The minimum interval between function executions.
  /// [cooldownLaunch] - When to start the cooldown period.
  /// [tickInterval] - Interval for timing updates during cooldown.
  /// [onCooldownStart] - Callback triggered when cooldown starts.
  /// [onCooldownTick] - Callback triggered on each tick during cooldown.
  /// [onCooldownEnd] - Callback triggered when cooldown ends.
  factory RateLimiter.throttle({
    Duration duration = Duration.zero,
    CooldownLaunch cooldownLaunch = CooldownLaunch.afterFunction,
    Duration tickInterval = const Duration(seconds: 1),
    void Function()? onCooldownStart,
    void Function(RateTimings timings)? onCooldownTick,
    void Function()? onCooldownEnd,
  }) =>
      Throttle(
        duration: duration,
        cooldownLaunch: cooldownLaunch,
        tickInterval: tickInterval,
        onCooldownStart: onCooldownStart,
        onCooldownTick: onCooldownTick,
        onCooldownEnd: onCooldownEnd,
      );

  /// Duration for rate limiting (delay or cooldown period)
  final Duration duration;

  /// {@template rate_limiter.process}
  /// Process a function with rate limiting applied
  ///
  /// This method applies the rate limiting strategy to the provided function
  /// and returns the result wrapped in a [RateOperationResult].
  /// {@endtemplate}
  ///
  /// [function] - The function to execute with rate limiting.
  /// [key] - Optional key to identify this operation.
  /// [container] - Optional operations container to use.
  Future<RateOperationResult<D>> process<D>(
    FutureOr<D> Function() function, {
    Object? key,
    OperationsContainer? container,
  });
}
