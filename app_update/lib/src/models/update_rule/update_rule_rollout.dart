import '../../entities/update_date.dart';
import '../../utils/mergeable.dart';

class UpdateRuleRollout {
  final UpdateDate? date;
  final Duration? delay;
  final Duration? gradualRolloutDuration;
  final double? userSegmentationPercent;
  final Map<String, dynamic>? customParams;

  const UpdateRuleRollout({
    this.date,
    this.delay,
    this.gradualRolloutDuration,
    this.userSegmentationPercent,
    this.customParams,
  });

  const UpdateRuleRollout.byRequired({
    required this.date,
    required this.delay,
    required this.gradualRolloutDuration,
    required this.userSegmentationPercent,
    required this.customParams,
  });

  UpdateRuleRollout copyWith({
    UpdateDate? date,
    Duration? delay,
    Duration? gradualRolloutDuration,
    double? userSegmentationPercent,
    Map<String, dynamic>? customParams,
  }) =>
      UpdateRuleRollout(
        date: date ?? this.date,
        delay: delay ?? this.delay,
        gradualRolloutDuration:
            gradualRolloutDuration ?? this.gradualRolloutDuration,
        userSegmentationPercent:
            userSegmentationPercent ?? this.userSegmentationPercent,
        customParams: Mergeable.mergeCustomParams(
          this.customParams,
          customParams,
        ),
      );
}
