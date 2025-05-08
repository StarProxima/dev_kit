// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'core/rate_operation.dart';
import 'core/rate_timings.dart';

import 'limiters/debounce.dart';
import 'limiters/throttle.dart';

/// Базовый класс для [Debounce] и [Throttle].
abstract class RateLimiter {
  RateLimiter({
    this.duration = Duration.zero,
  });

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

  final Duration duration;

  Future<RateOperationResult<D>> process<D>(
    FutureOr<D> Function() function, {
    Object? tag,
    RateOperationsContainer? container,
  });
}
