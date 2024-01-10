import 'dart:async';

import 'package:flutter/foundation.dart';

import 'rate_operation.dart';

sealed class RateResult<T> {
  const RateResult();
}

class RateSuccess<T> extends RateResult<T> {
  const RateSuccess(this.data);
  final T data;
}

class RateCancel<T> extends RateResult<T> {}

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
    Map<String, RateOperation> operations,
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
    Map<String, RateOperation> operations,
    FutureOr<T> Function() function,
  ) async {
    final tag = this.tag ?? StackTrace.current.toString();
    final completer = Completer<RateResult<T>>();

    operations.remove(tag)
      ?..rateLimiter?.onCancelOperation?.call()
      ..cancel();

    operations[tag] = RateOperation<T>(
      timer: Timer(this, () async {
        final op = operations[tag];
        final future = op?.complete();
        if (includeRequestTime) await future;
        if (operations.containsValue(op)) operations.remove(tag);
      }),
      completer: completer,
      function: function,
      rateLimiter: this,
    );
    final res = await completer.future;
    // Если операция была отменена в течении debounce, то возвращается null.
    // Eсли includeRequestTime, то при отмене null вернётся, даже если выполение функции уже началось.
    // При этом не вызывается ни onSuccess, ни onError.
    return res;
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
    Map<String, RateOperation> operations,
    FutureOr<T> Function() function,
  ) async {
    final tag = this.tag ?? StackTrace.current.toString();
    // Если операция уже существует, то возвращается null.
    // При этом не вызывается ни onSuccess, ни onError.

    if (operations.containsKey(tag)) {
      onCancelOperation?.call();
      return RateCancel();
    }

    operations[tag] = RateOperation();

    final futureOr = includeRequestTime ? await function() : function();

    final control = this.control;

    Timer? timer;

    if (control != null) {
      control.onTick(this);

      timer = Timer.periodic(
        control.tick,
        (timer) {
          final remainingMilliseconds =
              inMilliseconds - timer.tick * control.tick.inMilliseconds;

          control.onTick(Duration(milliseconds: remainingMilliseconds));
        },
      );
    }

    operations[tag] = RateOperation<T>(
      timer: Timer(this, () {
        operations.remove(tag);
        timer?.cancel();
        control?.onTick(Duration.zero);
      }),
    );
    final data = await futureOr;
    return RateSuccess(data);
  }
}

class CooldownControl {
  CooldownControl({
    required this.tick,
    required this.onTick,
  });

  final Duration tick;
  final void Function(Duration remainingTime) onTick;
}
