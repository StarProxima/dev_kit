import 'dart:async';

import 'internal_api_wrap.dart';
import 'rate_limiter.dart';

/// Операция для debounce и thottle в [InternalApiWrap]
class RateOperation<T> {
  RateOperation({
    this.timer,
    this.completer,
    this.function,
    this.rateLimiter,
  });

  final Timer? timer;
  final Completer<T?>? completer;
  final FutureOr<T> Function()? function;
  final RateLimiter? rateLimiter;

  void cancel() {
    timer?.cancel();
    if (completer?.isCompleted ?? true) return;
    completer?.complete(null);
  }

  Future<void> complete() async {
    timer?.cancel();
    try {
      final res = await function?.call();
      if (completer?.isCompleted ?? true) return;
      completer?.complete(res);
    } catch (e, s) {
      if (completer?.isCompleted ?? true) return;
      completer?.complete(Future.error(e, s));
    }
  }
}
