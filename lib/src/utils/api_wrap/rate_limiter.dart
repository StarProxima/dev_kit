part of 'api_wrap.dart';

/// Базовый класс для [Debounce] и [Throttle].
sealed class RateLimiter<T> {
  const RateLimiter({
    this.tag,
    this.onCancelOperation,
    this.duration = Duration.zero,
  });

  final String? tag;
  final T? Function()? onCancelOperation;
  final Duration duration;

  Future<RateOperationResult<T>> process({
    required RateOperationsContainer container,
    required String defaultTag,
    required FutureOr<T> Function() function,
  });
}

class Debounce<T> extends RateLimiter<T> {
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
  Future<RateOperationResult<T>> process({
    required RateOperationsContainer container,
    required String defaultTag,
    required FutureOr<T> Function() function,
  }) async {
    final tag = this.tag ?? defaultTag;
    final completer = Completer<RateOperationResult<T>>();

    final operations = container.debounceOperations;

    // Если операция была отменена в течении debounce, то возвращается null.
    // Eсли includeRequestTime, то при отмене null вернётся, даже если выполение функции уже началось.
    // При этом не вызывается ни onSuccess, ни onError.
    operations.remove(tag)?.cancel(
          rateCancel: RateOperationCancel(rateLimiter: 'Debounce', tag: tag),
        );

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

class Throttle<T> extends RateLimiter<T> {
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
  Future<RateOperationResult<T>> process({
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
      return RateOperationCancel(
        rateLimiter: 'Throttle',
        tag: tag,
      );
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
    return RateOperationSuccess(data);
  }
}
