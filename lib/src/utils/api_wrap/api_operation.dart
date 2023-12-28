import 'dart:async';

import '../../../app_dev_kit.dart';
import 'internal_api_wrap.dart';

/// Операция для debounce и thottle в [InternalApiWrap]
class ApiOperation<T> {
  ApiOperation({
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
