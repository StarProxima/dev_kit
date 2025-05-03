import 'package:api_wrap/api_wrap.dart';
import 'package:meta/meta.dart';

import 'limiters/debounce.dart';
import 'limiters/throttle.dart';
import 'rate_limiter.dart';
import 'utils.dart';

sealed class RateOperationResult<T> {
  const RateOperationResult();
}

class RateOperationSuccess<T> extends RateOperationResult<T> {
  const RateOperationSuccess(this.data);
  final T data;
}

class RateOperationCancel<T> implements RateOperationResult<T> {
  RateOperationCancel({
    required this.rateLimiter,
    required this.tag,
    required this.timings,
  });

  final String rateLimiter;
  final Object tag;
  final RateTimings timings;
}

class RateOperationsContainer {
  RateOperationsContainer();

  final Map<Object, DebounceOperation> debounceOperations = {};
  final Map<Object, ThrottleOperation> throttleOperations = {};
  final Map<Object, QueueOperation> queueOperations = {};
}

abstract class RateOperation<T> {
  RateOperation({
    required this.rateLimiter,
  });

  final RateLimiter rateLimiter;
  @protected
  DateTime? startAt;

  RateTimings calculateRateTimings({
    Duration? elapsedTime,
    Duration? remainingTime,
  }) {
    elapsedTime = elapsedTime ??
        (startAt != null ? DateTime.now().difference(startAt!) : Duration.zero);

    return RateTimings(
      duration: rateLimiter.duration,
      elapsedTime: elapsedTime,
      remainingTime: remainingTime,
    );
  }
}
