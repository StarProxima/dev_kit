// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import '../operations_container.dart';
import 'core/rate_operation.dart';
import 'core/rate_timings.dart';

import 'limiters/debounce.dart';
import 'limiters/throttle.dart';

/// Base class for rate limiters like [Debounce] and [Throttle].
abstract class RateLimiter {
  RateLimiter({
    this.duration = Duration.zero,
  });

  /// Creates a debounce rate limiter.
  ///
  /// Debounce delays function execution until specified time has passed
  /// since the last call.
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
        canCancelRunningFunction: false,
        tickInterval: tickInterval,
        onDelayStart: onDelayStart,
        onDelayTick: onDelayTick,
        onDelayEnd: onDelayEnd,
      );

  /// Creates a throttle rate limiter.
  ///
  /// Throttle limits the execution frequency of a function,
  /// ensuring a minimum interval between executions.
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

  /// Process a function with rate limiting applied
  ///
  /// [function] The function to execute with rate limiting
  /// [key] Optional key to identify this operation
  /// [container] Optional operations container to use
  Future<RateOperationResult<D>> process<D>(
    FutureOr<D> Function() function, {
    Object? key,
    OperationsContainer? container,
  });
}
