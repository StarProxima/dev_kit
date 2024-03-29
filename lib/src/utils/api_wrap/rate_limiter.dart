part of 'api_wrap.dart';

/// Базовый класс для [Debounce] и [Throttle].
sealed class RateLimiter {
  const RateLimiter({
    this.tag,
    this.onCancelOperation,
    this.duration = Duration.zero,
  });

  final String? tag;
  final VoidCallback? onCancelOperation;
  final Duration duration;

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
    super.duration,
    this.shouldCancelRunningOperations = true,
    super.onCancelOperation,
  });

  final bool shouldCancelRunningOperations;

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

    operations[tag] = DebounceOperation<T>(
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
    super.onCancelOperation,
  });

  final CooldownLaunch cooldownLaunch;
  final Duration cooldownTickDelay;
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

    Timer? cooldownTickTimer;

    final operation = ThrottleOperation<T>(
      onCooldownEnd: () {
        operations.remove(tag);
        cooldownTickTimer?.cancel();
        onTickCooldown?.call(Duration.zero);
        onEndCooldown?.call();
      },
    );
    operations[tag] = operation;

    final FutureOr<T> futureOr;

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
          onTickCooldown!(duration);
          cooldownTickTimer = Timer.periodic(
            cooldownTickDelay,
            (timer) {
              final remainingMilliseconds = duration.inMilliseconds -
                  timer.tick * cooldownTickDelay.inMilliseconds;

              onTickCooldown!(Duration(milliseconds: remainingMilliseconds));
            },
          );
        }
      }

      if (!operation.cooldownIsCancel) {
        operation.startCooldown(duration: duration);
      }
    }

    final data = await futureOr;
    return RateSuccess(data);
  }
}
