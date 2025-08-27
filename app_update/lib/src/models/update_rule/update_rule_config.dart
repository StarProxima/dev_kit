import '../../entities/app_status.dart';
import '../../entities/update_date.dart';
import '../../entities/update_locale.dart';
import '../../entities/update_source.dart';
import '../../entities/update_version_constraint.dart';
import '../../entities/update_view_target.dart';
import '../../utils/mergeable.dart';

class UpdateRuleConfig<T extends Mergeable<T>> {
  final List<AppStatus>? appStatusIs;
  final List<UpdateLocale>? localeIs;
  final List<UpdateViewTarget>? viewTargetIs;
  final List<UpdateVersionConstraint>? versionIs;
  final List<UpdateSource>? sourceIs;
  final UpdateDate? date;
  final Duration? delay;
  final Duration? rollout;
  final double? segmentationPercent;
  final Map<String, dynamic>? customData;
  final T data;

  const UpdateRuleConfig({
    this.appStatusIs,
    this.localeIs,
    this.viewTargetIs,
    this.versionIs,
    this.sourceIs,
    this.date,
    this.delay,
    this.rollout,
    this.segmentationPercent,
    this.customData,
    required this.data,
  });

  const UpdateRuleConfig.byRequired({
    required this.appStatusIs,
    required this.localeIs,
    required this.viewTargetIs,
    required this.versionIs,
    required this.sourceIs,
    required this.date,
    required this.delay,
    required this.rollout,
    required this.segmentationPercent,
    required this.data,
    required this.customData,
  });

  UpdateRuleConfig<T> copyWith({
    List<AppStatus>? appStatusIs,
    List<UpdateLocale>? localeIs,
    List<UpdateViewTarget>? viewTargetIs,
    List<UpdateVersionConstraint>? versionIs,
    List<UpdateSource>? sourceIs,
    UpdateDate? date,
    Duration? delay,
    Duration? rollout,
    double? segmentationPercent,
    Map<String, dynamic>? customData,
    T? data,
  }) =>
      UpdateRuleConfig.byRequired(
        appStatusIs: appStatusIs ?? this.appStatusIs,
        localeIs: localeIs ?? this.localeIs,
        viewTargetIs: viewTargetIs ?? this.viewTargetIs,
        versionIs: versionIs ?? this.versionIs,
        sourceIs: sourceIs ?? this.sourceIs,
        date: date ?? this.date,
        delay: delay ?? this.delay,
        rollout: rollout ?? this.rollout,
        segmentationPercent: segmentationPercent ?? this.segmentationPercent,
        data: data ?? this.data,
        customData: Mergeable.mergeCustomData(this.customData, customData),
      );
}
