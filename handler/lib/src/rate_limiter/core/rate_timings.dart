import 'package:meta/meta.dart';

/// {@template rate_timings}
/// Represents timing information for rate-limited operations.
///
/// Tracks duration, elapsed time, and remaining time for operations
/// to provide feedback about their progress and state.
/// {@endtemplate}
@immutable
class RateTimings {
  /// {@macro rate_timings}
  ///
  /// [duration] - The total duration of the rate-limiting period.
  /// [elapsedTime] - How much time has elapsed since the operation started.
  /// [remainingTime] - Optional explicit remaining time, otherwise calculated from duration and elapsed time.
  const RateTimings({
    required this.duration,
    required this.elapsedTime,
    required Duration? remainingTime,
  }) : _remainingTime = remainingTime;

  /// The total duration of the rate-limiting period
  final Duration duration;

  /// How much time has elapsed since the operation started
  final Duration elapsedTime;

  /// Explicit remaining time, if provided
  final Duration? _remainingTime;

  /// The remaining time until the operation completes.
  ///
  /// If an explicit remaining time was provided in the constructor, that value is used.
  /// Otherwise, calculated as (duration - elapsedTime).
  Duration get remainingTime => _remainingTime ?? duration - elapsedTime;

  @override
  bool operator ==(covariant RateTimings other) {
    if (identical(this, other)) return true;

    return other.duration == duration && other.elapsedTime == elapsedTime;
  }

  @override
  int get hashCode => duration.hashCode ^ elapsedTime.hashCode;

  @override
  String toString() =>
      'RateTimings(duration: $duration, elapsedTime: $elapsedTime, remainingTime: $remainingTime)';
}
