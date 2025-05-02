// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:async';

import 'rate_operation.dart';
import 'utils.dart';

import 'limiters/debounce.dart';
import 'limiters/throttle.dart';

/// Базовый класс для [Debounce] и [Throttle].
abstract class RateLimiter {
  RateLimiter({
    this.duration = Duration.zero,
  });

  factory RateLimiter.debounce({
    Duration duration,
    bool shouldCancelRunningOperations,
    Duration delayTickInterval,
    void Function()? onDelayStart,
    void Function(RateTimings timings)? onDelayTick,
    void Function()? onDelayEnd,
  }) = Debounce;

  factory RateLimiter.throttle({
    Duration duration,
    CooldownLaunch cooldownLaunch,
    Duration cooldownTickInterval,
    void Function()? onCooldownStart,
    void Function(RateTimings timings)? onCooldownTick,
    void Function()? onCooldownEnd,
  }) = Throttle;

  final Duration duration;

  Future<RateOperationResult<D>> process<D>(
    FutureOr<D> Function() function, {
    Object? tag,
    RateOperationsContainer? container,
  });
}
