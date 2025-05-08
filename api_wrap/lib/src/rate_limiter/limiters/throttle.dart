import 'dart:async';

import '../rate_limiter.dart';
import '../core/rate_operation.dart';
import '../core/rate_timings.dart';

/// Варианты запуска cooldown.
enum CooldownLaunch {
  /// Cooldown начнётся сразу после начала выполнения запроса.
  immediately,

  /// Cooldown начнётся сразу после выполнения запроса.
  afterFunction,
}

class Throttle extends RateLimiter {
  /// Сразу вызывает функцию.
  ///
  /// Если в течении заданного времени метод будет вызван ещё раз с тем же [tag], то новый запрос не выполнится.
  Throttle({
    super.duration,
    this.cooldownLaunch = CooldownLaunch.afterFunction,
    this.tickInterval = const Duration(seconds: 1),
    this.onCooldownStart,
    this.onCooldownTick,
    this.onCooldownEnd,
  });

  final CooldownLaunch cooldownLaunch;

  final Duration tickInterval;
  final void Function()? onCooldownStart;
  final void Function(RateTimings timings)? onCooldownTick;
  final void Function()? onCooldownEnd;

  final container = RateOperationsContainer();

  /// [key] - тег для идентификации запроса, если не указан, то используется [StackTrace.current].
  @override
  Future<RateOperationResult<D>> process<D>(
    FutureOr<D> Function() function, {
    Object? key,
    RateOperationsContainer? container,
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
    startAt = DateTime.now();
    _timer = Timer(duration, cancelCooldown);
  }

  void cancelCooldown() {
    cooldownIsCancel = true;
    _timer.cancel();
    onCooldownEnd();
  }
}
