import 'dart:async';

import 'api_operation.dart';

/// Базовый класс для [Debounce] и [Throttle].
sealed class RateLimiter extends Duration {
  RateLimiter({
    this.tag,
    super.milliseconds,
    super.seconds,
    super.minutes,
  });

  final String? tag;

  Future<T?> call<T>(
    Map<String, ApiOperation> operations,
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
    super.milliseconds,
    super.seconds,
    super.minutes,
  });

  final bool includeRequestTime;

  @override
  Future<T?> call<T>(
    Map<String, ApiOperation> operations,
    FutureOr<T> Function() function,
  ) async {
    final tag = this.tag ?? StackTrace.current.toString();
    final completer = Completer<T?>();

    operations.remove(tag)?.cancel();

    operations[tag] = ApiOperation<T>(
      timer: Timer(this, () async {
        final op = operations[tag];
        final future = op?.complete();
        if (includeRequestTime) await future;
        if (operations.containsValue(op)) operations.remove(tag);
      }),
      completer: completer,
      function: function,
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
    super.milliseconds,
    super.seconds,
    super.minutes,
  });

  final bool includeRequestTime;

  @override
  Future<T?> call<T>(
    Map<String, ApiOperation> operations,
    FutureOr<T> Function() function,
  ) async {
    final tag = this.tag ?? StackTrace.current.toString();
    // Если операция уже существует, то возвращается null.
    // При этом не вызывается ни onSuccess, ни onError.
    if (operations.containsKey(tag)) return null;
    operations[tag] = ApiOperation();

    final futureOr = includeRequestTime ? await function() : function();
    operations[tag] = ApiOperation<T>(
      timer: Timer(this, () => operations.remove(tag)),
    );
    return futureOr;
  }
}
