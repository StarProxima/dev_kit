part of 'api_wrap.dart';

/// Базовый класс для [Debounce] и [Throttle].
sealed class RateLimiter extends Duration {
  RateLimiter({
    this.tag,
    this.onCancelOperation,
    super.milliseconds,
    super.seconds,
    super.minutes,
  });

  final String? tag;
  final VoidCallback? onCancelOperation;

  Future<RateResult<T>> process<T>(
    RateOperationsContainer container,
    FutureOr<T> Function() function,
  );
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
    this.includeRequestTime = true,
    super.onCancelOperation,
    super.milliseconds,
    super.seconds,
    super.minutes,
  });

  final bool includeRequestTime;

  @override
  Future<RateResult<T>> process<T>(
    RateOperationsContainer container,
    FutureOr<T> Function() function,
  ) async {
    final tag = this.tag ?? StackTrace.current.toString();
    final completer = Completer<RateResult<T>>();

    final operations = container.debounceOperations;

    // Если операция была отменена в течении debounce, то возвращается null.
    // Eсли includeRequestTime, то при отмене null вернётся, даже если выполение функции уже началось.
    // При этом не вызывается ни onSuccess, ни onError.
    operations.remove(tag)?.cancel();

    operations[tag] = DebounceOperation(
      timer: Timer(this, () async {
        final operation = operations[tag];
        final future = operation?.complete();
        if (includeRequestTime) await future;
        if (operations.containsValue(operation)) operations.remove(tag);
      }),
      completer: completer,
      function: function,
      rateLimiter: this,
    );

    final result = await completer.future;
    return result;
  }
}

class Throttle extends RateLimiter {
  /// Сразу вызывает функцию.
  ///
  /// Если в течении заданного времени метод будет вызван ещё раз с тем же [tag], то новый запрос не выполнится.
  ///
  /// [tag] - тег для идентификации запроса, если не указан, то используется [StackTrace.current].
  Throttle({
    super.tag,
    this.includeRequestTime = true,
    this.control,
    super.onCancelOperation,
    super.milliseconds,
    super.seconds,
    super.minutes,
  });

  final bool includeRequestTime;
  final CooldownControl? control;

  @override
  Future<RateResult<T>> process<T>(
    RateOperationsContainer container,
    FutureOr<T> Function() function,
  ) async {
    final tag = this.tag ?? StackTrace.current.toString();

    final operations = container.throttleOperations;

    if (operations.containsKey(tag)) {
      // Если операция уже существует, то возвращается null.
      // При этом не вызывается ни onSuccess, ни onError.
      onCancelOperation?.call();
      return RateCancel();
    }

    final operation = ThrottleOperation(
      onCooldownEnd: () {
        operations.remove(tag);
      },
    );
    operations[tag] = operation;

    final futureOr = includeRequestTime ? await function() : function();

    final control = this.control;
    final onTick = control?.onTick;
    Timer? cooldownControlTimer;

    if (!operation.cooldownIsCancel && control != null) {
      control.onStart?.call();

      if (onTick != null) {
        onTick(this);
        cooldownControlTimer = Timer.periodic(
          control.tick,
          (timer) {
            final remainingMilliseconds =
                inMilliseconds - timer.tick * control.tick.inMilliseconds;

            onTick(Duration(milliseconds: remainingMilliseconds));
          },
        );
      }
    }

    if (!operation.cooldownIsCancel) {
      operation.startCooldown(
        duration: this,
        callback: () {
          operations.remove(tag);
          cooldownControlTimer?.cancel();
          onTick?.call(Duration.zero);
          control?.onEnd?.call();
        },
      );
    }

    final data = await futureOr;
    return RateSuccess(data);
  }
}

class CooldownControl {
  CooldownControl({
    this.tick = const Duration(seconds: 1),
    this.onTick,
    this.onStart,
    this.onEnd,
  });

  final Duration tick;
  final void Function(Duration remainingTime)? onTick;
  final void Function()? onStart;
  final void Function()? onEnd;
}
