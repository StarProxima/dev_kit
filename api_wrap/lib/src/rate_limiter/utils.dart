import 'package:meta/meta.dart';

@immutable
class RateTimings {
  const RateTimings({
    required this.duration,
    required this.elapsedTime,
    required Duration? remainingTime,
  }) : _remainingTime = remainingTime;

  final Duration duration;
  final Duration elapsedTime;
  final Duration? _remainingTime;

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
