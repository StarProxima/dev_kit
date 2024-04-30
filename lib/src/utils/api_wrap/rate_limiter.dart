// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'api_wrap.dart';

@immutable
class RateTimings {
  const RateTimings(
    this.duration,
    this.elapsedTime,
  );

  final Duration duration;
  final Duration elapsedTime;
  Duration get remainingTime => duration - elapsedTime;

  @override
  bool operator ==(covariant RateTimings other) {
    if (identical(this, other)) return true;

    return other.duration == duration && other.elapsedTime == elapsedTime;
  }

  @override
  int get hashCode => duration.hashCode ^ elapsedTime.hashCode;

  @override
  String toString() =>
      'RateTimings(duration: $duration, elapsedTime: $elapsedTime, remainingTime: $remainingTime)';
}

/// Базовый класс для [Debounce] и [Throttle].
sealed class RateLimiter {
  RateLimiter({
    this.tag,
    this.duration = Duration.zero,
  });

  final String? tag;
  final Duration duration;

  Future<RateOperationResult<D>> process<D>({
    required RateOperationsContainer container,
    required String defaultTag,
    required FutureOr<D> Function() function,
  });
}

class Debounce extends RateLimiter {
  /// Задержит выполнение на заданное время.
  ///
  /// Если метод будет вызван ещё раз с тем же [tag],
  /// то предыдущий запрос будет отменён, а новый выполнится через заданное время.
  ///
  /// [tag] - тег для идентификации запроса, если не указан, то используется [StackTrace.current].
  Debounce({
    super.tag,
    super.duration,
    this.shouldCancelRunningOperations = true,
  });

  final bool shouldCancelRunningOperations;

  @override
  Future<RateOperationResult<D>> process<D>({
    required RateOperationsContainer container,
    required String defaultTag,
    required FutureOr<D> Function() function,
  }) async {
    final tag = this.tag ?? defaultTag;
    final completer = Completer<RateOperationResult<D>>();

    final operations = container.debounceOperations;

    final operation = operations[tag];
    operation?.cancel(
      rateCancel: RateOperationCancel<D>(
        rateLimiter: 'Debounce',
        tag: tag,
        timings: operation.calculateRateTimings(),
      ),
    );

    operations[tag] = DebounceOperation<D>(
      timer: Timer(duration, () async {
        final operation = operations[tag];
        final future = operation?.complete();
        try {
          if (shouldCancelRunningOperations) await future;
        } catch (_) {
          rethrow;
        } finally {
          if (operations.containsValue(operation)) operations.remove(tag);
        }
      }),
      completer: completer,
      function: function,
      rateLimiter: this,
    );

    return completer.future;
  }
}

/// Варианты запуска cooldown.
enum CooldownLaunch {
  /// Cooldown начнётся сразу после начала выполнения запроса.
  immediately,

  /// Cooldown начнётся сразу после выполнения запроса.
  afterOperaion,
}

class Throttle extends RateLimiter {
  /// Сразу вызывает функцию.
  ///
  /// Если в течении заданного времени метод будет вызван ещё раз с тем же [tag], то новый запрос не выполнится.
  ///
  /// [tag] - тег для идентификации запроса, если не указан, то используется [StackTrace.current].
  Throttle({
    super.tag,
    super.duration,
    this.cooldownLaunch = CooldownLaunch.afterOperaion,
    this.cooldownTickDelay = const Duration(seconds: 1),
    this.onTickCooldown,
    this.onStartCooldown,
    this.onEndCooldown,
  });

  final CooldownLaunch cooldownLaunch;
  final Duration cooldownTickDelay;
  final void Function(RateTimings timings)? onTickCooldown;
  final void Function()? onStartCooldown;
  final void Function()? onEndCooldown;

  @override
  Future<RateOperationResult<D>> process<D>({
    required RateOperationsContainer container,
    required String defaultTag,
    required FutureOr<D> Function() function,
  }) async {
    final tag = this.tag ?? defaultTag;

    final operations = container.throttleOperations;
    final existingOperation = operations[tag];

    if (existingOperation != null) {
      return RateOperationCancel<D>(
        rateLimiter: 'Throttle',
        tag: tag,
        timings: existingOperation.calculateRateTimings(),
      );
    }

    Timer? cooldownTickTimer;

    final operation = ThrottleOperation<D>(
      rateLimiter: this,
      onCooldownEnd: () {
        final operation = operations.remove(tag);
        cooldownTickTimer?.cancel();

        if (operation == null) return;

        onTickCooldown?.call(
          operation.calculateRateTimings(
            elapsedTime: operation.rateLimiter.duration,
          ),
        );
        onEndCooldown?.call();
      },
    );
    operations[tag] = operation;

    final FutureOr<D> futureOr;

    try {
      futureOr = cooldownLaunch == CooldownLaunch.afterOperaion
          ? await function()
          : function();
    } catch (_) {
      rethrow;
    } finally {
      if (!operation.cooldownIsCancel) {
        onStartCooldown?.call();

        if (onTickCooldown != null) {
          onTickCooldown!(RateTimings(duration, Duration.zero));
          cooldownTickTimer = Timer.periodic(
            cooldownTickDelay,
            (timer) {
              if (operation.cooldownIsCancel) {
                timer.cancel();
                return;
              }
              final timings = operation.calculateRateTimings(
                elapsedTime: Duration(
                  milliseconds: timer.tick * cooldownTickDelay.inMilliseconds,
                ),
              );
              onTickCooldown!(timings);
            },
          );
        }
      }

      if (!operation.cooldownIsCancel) {
        operation.startCooldown(duration: duration);
      }
    }

    final data = await futureOr;
    return RateOperationSuccess(data);
  }
}
