import 'package:meta/meta.dart';

import '../rate_limiter.dart';
import 'rate_timings.dart';

/// {@template rate_operation_result}
/// Base class for results of rate-limited operations.
///
/// Provides a sealed hierarchy to represent different operation outcomes.
/// {@endtemplate}
sealed class RateOperationResult<T> {
  /// {@macro rate_operation_result}
  const RateOperationResult();
}

/// {@template rate_operation_success}
/// Represents a successful rate-limited operation with its result data.
///
/// Created when an operation completes successfully and returns data.
/// {@endtemplate}
class RateOperationSuccess<T> extends RateOperationResult<T> {
  /// {@macro rate_operation_success}
  ///
  /// [data] - The result data from the operation.
  const RateOperationSuccess(this.data);

  /// The result data from the operation
  final T data;
}

/// {@template rate_operation_cancel}
/// Represents a canceled rate-limited operation with contextual information.
///
/// Created when an operation is canceled before completion, containing
/// timing information about when it was canceled.
/// {@endtemplate}
class RateOperationCancel<T> implements RateOperationResult<T> {
  /// {@macro rate_operation_cancel}
  ///
  /// [key] - The key that identified the operation.
  /// [timings] - Timing information about the operation.
  RateOperationCancel({
    required this.key,
    required this.timings,
  });

  /// The key that identified the operation
  final Object key;

  /// Timing information about the operation
  final RateTimings timings;
}

/// {@template rate_operation}
/// Abstract base class for rate-limited operations.
///
/// Provides common functionality for different types of rate-limited
/// operations like debounce and throttle.
/// {@endtemplate}
abstract class RateOperation<T> {
  /// {@macro rate_operation}
  ///
  /// [rateLimiter] - The rate limiter that created this operation.
  RateOperation({
    required this.rateLimiter,
  });

  /// The rate limiter that created this operation
  final RateLimiter rateLimiter;

  /// The time when this operation started, used for timing calculations
  @protected
  DateTime? startAt;

  /// Calculate timing information for the operation
  ///
  /// [elapsedTime] - Optional explicit elapsed time, otherwise calculated from [startAt].
  /// [remainingTime] - Optional remaining time until operation completes.
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
