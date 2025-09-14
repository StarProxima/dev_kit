import '../../entities/update_date.dart';
import '../../utils/mergeable.dart';

class UpdateRuleRollout {
  final UpdateDate? date;
  final Duration? delay;
  final Duration? rollout;
  final double? segmentationPercent;
  final Map<String, dynamic>? customParams;

  const UpdateRuleRollout({
    this.date,
    this.delay,
    this.rollout,
    this.segmentationPercent,
    this.customParams,
  });

  const UpdateRuleRollout.byRequired({
    required this.date,
    required this.delay,
    required this.rollout,
    required this.segmentationPercent,
    required this.customParams,
  });

  UpdateRuleRollout copyWith({
    UpdateDate? date,
    Duration? delay,
    Duration? rollout,
    double? segmentationPercent,
    Map<String, dynamic>? customParams,
  }) =>
      UpdateRuleRollout(
        date: date ?? this.date,
        delay: delay ?? this.delay,
        rollout: rollout ?? this.rollout,
        segmentationPercent: segmentationPercent ?? this.segmentationPercent,
        customParams: Mergeable.mergeCustomParams(
          this.customParams,
          customParams,
        ),
      );
}
