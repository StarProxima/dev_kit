import 'package:meta/meta.dart';

import '../rate_limiter.dart';
import 'rate_timings.dart';

/// Base class for operation results
sealed class RateOperationResult<T> {
  const RateOperationResult();
}

/// Represents a successful operation with its result data
class RateOperationSuccess<T> extends RateOperationResult<T> {
  const RateOperationSuccess(this.data);
  final T data;
}

/// Represents a canceled operation with contextual information
class RateOperationCancel<T> implements RateOperationResult<T> {
  RateOperationCancel({
    required this.key,
    required this.timings,
  });

  final Object key;
  final RateTimings timings;
}

/// Abstract base class for rate-limited operations
abstract class RateOperation<T> {
  RateOperation({
    required this.rateLimiter,
  });

  final RateLimiter rateLimiter;
  @protected
  DateTime? startAt;

  /// Calculate timing information for the operation
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
