import 'dart:async';
import 'dart:collection';

import '../rate_limiter.dart';
import '../rate_operation.dart';
import '../utils.dart';

/// Варианты запуска cooldown.
enum TimerLaunch {
  /// Cooldown начнётся сразу после начала выполнения запроса.
  immediately,

  /// Cooldown начнётся сразу после выполнения запроса.
  afterFunction,
}

class Queue extends RateLimiter {
  /// Сразу вызывает функцию.
  ///
  /// Если в течении заданного времени метод будет вызван ещё раз с тем же [tag], то новый запрос не выполнится.
  ///
  /// [tag] - тег для идентификации запроса, если не указан, то используется [StackTrace.current].
  Queue({
    super.duration,
    this.cooldownLaunch = TimerLaunch.afterFunction,
    this.tickInterval = const Duration(seconds: 1),
    this.onCooldownStart,
    this.onCooldownTick,
    this.onCooldownEnd,
  });

  final TimerLaunch cooldownLaunch;

  final Duration tickInterval;
  final void Function()? onCooldownStart;
  final void Function(RateTimings timings)? onCooldownTick;
  final void Function()? onCooldownEnd;

  final container = RateOperationsContainer();

  @override
  Future<RateOperationResult<D>> process<D>(
    FutureOr<D> Function() function, {
    Object? tag,
    RateOperationsContainer? container,
  }) async {
    tag ??= '${StackTrace.current}';
    final operations = (container ?? this.container).queueOperations;
    final existingOperation = operations[tag];

    if (existingOperation != null) {
      return RateOperationCancel<D>(
        rateLimiter: 'Queue',
        tag: tag,
        timings: existingOperation.calculateRateTimings(),
      );
    }

    Timer? cooldownTickTimer;

    final operation = QueueOperation<D>(
      rateLimiter: this,
      onCooldownEnd: () {
        final operation = operations.remove(tag);
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

    operations[tag] = operation;

    final FutureOr<D> futureOr;

    try {
      futureOr = cooldownLaunch == TimerLaunch.afterFunction
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

class QueueOperation<T> extends RateOperation<T> {
  QueueOperation({
    required super.rateLimiter,
    required this.onCooldownEnd,
  });

  final void Function() onCooldownEnd;
  bool cooldownIsCancel = false;
  late Timer _timer;

  final ListQueue<Completer<void>> queue;

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
