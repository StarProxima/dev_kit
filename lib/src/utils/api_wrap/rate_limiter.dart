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

  Future<RateResult<T>> process<T>({
    required RateOperationsContainer container,
    required String defaultTag,
    required FutureOr<T> Function() function,
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
    this.includeRequestTime = true,
    super.onCancelOperation,
    super.milliseconds,
    super.seconds,
    super.minutes,
  });

  final bool includeRequestTime;

  @override
  Future<RateResult<T>> process<T>({
    required RateOperationsContainer container,
    required String defaultTag,
    required FutureOr<T> Function() function,
  }) async {
    final tag = this.tag ?? defaultTag;
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
    this.cooldownTick = const Duration(seconds: 1),
    this.onTickCooldown,
    this.onStartCooldown,
    this.onEndCooldown,
    super.onCancelOperation,
    super.milliseconds,
    super.seconds,
    super.minutes,
  });

  final bool includeRequestTime;
  final Duration cooldownTick;
  final void Function(Duration remainingTime)? onTickCooldown;
  final void Function()? onStartCooldown;
  final void Function()? onEndCooldown;

  @override
  Future<RateResult<T>> process<T>({
    required RateOperationsContainer container,
    required String defaultTag,
    required FutureOr<T> Function() function,
  }) async {
    final tag = this.tag ?? defaultTag;

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

    Timer? cooldownControlTimer;

    if (!operation.cooldownIsCancel) {
      onStartCooldown?.call();

      if (onTickCooldown != null) {
        onTickCooldown!(this);
        cooldownControlTimer = Timer.periodic(
          cooldownTick,
          (timer) {
            final remainingMilliseconds =
                inMilliseconds - timer.tick * cooldownTick.inMilliseconds;

            onTickCooldown!(Duration(milliseconds: remainingMilliseconds));
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
          onTickCooldown?.call(Duration.zero);
          onEndCooldown?.call();
        },
      );
    }

    final data = await futureOr;
    return RateSuccess(data);
  }
}
