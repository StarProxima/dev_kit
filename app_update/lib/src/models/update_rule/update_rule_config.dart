import '../../entities/app_status.dart';
import '../../entities/update_date.dart';
import '../../entities/update_locale.dart';
import '../../entities/update_platform.dart';
import '../../entities/update_source.dart';
import '../../entities/update_version_constraint.dart';
import '../../entities/update_view_target.dart';
import '../../utils/mergeable.dart';

class UpdateRuleConfig<T extends Mergeable<T>> {
  final List<AppStatus>? appStatusIs;
  final List<UpdateLocale>? localeIs;
  final List<UpdateViewTarget>? viewTargetIs;
  final List<UpdateVersionConstraint>? appVersionIs;
  final List<UpdateSource>? sourceIs;
  final List<UpdatePlatform>? platformIs;
  final UpdateDate? date;
  final Duration? delay;
  final Duration? rollout;
  final double? segmentationPercent;
  final Map<String, dynamic>? customParams;
  final T data;

  const UpdateRuleConfig({
    this.appStatusIs,
    this.localeIs,
    this.viewTargetIs,
    this.appVersionIs,
    this.sourceIs,
    this.platformIs,
    this.date,
    this.delay,
    this.rollout,
    this.segmentationPercent,
    this.customParams,
    required this.data,
  });

  const UpdateRuleConfig.byRequired({
    required this.appStatusIs,
    required this.localeIs,
    required this.viewTargetIs,
    required this.appVersionIs,
    required this.sourceIs,
    required this.platformIs,
    required this.date,
    required this.delay,
    required this.rollout,
    required this.segmentationPercent,
    required this.data,
    required this.customParams,
  });

  UpdateRuleConfig<T> copyWith({
    List<AppStatus>? appStatusIs,
    List<UpdateLocale>? localeIs,
    List<UpdateViewTarget>? viewTargetIs,
    List<UpdateVersionConstraint>? appVersionIs,
    List<UpdateSource>? sourceIs,
    List<UpdatePlatform>? platformIs,
    UpdateDate? date,
    Duration? delay,
    Duration? rollout,
    double? segmentationPercent,
    Map<String, dynamic>? customParams,
    T? data,
  }) =>
      UpdateRuleConfig.byRequired(
        appStatusIs: appStatusIs ?? this.appStatusIs,
        localeIs: localeIs ?? this.localeIs,
        viewTargetIs: viewTargetIs ?? this.viewTargetIs,
        appVersionIs: appVersionIs ?? this.appVersionIs,
        sourceIs: sourceIs ?? this.sourceIs,
        platformIs: platformIs ?? this.platformIs,
        date: date ?? this.date,
        delay: delay ?? this.delay,
        rollout: rollout ?? this.rollout,
        segmentationPercent: segmentationPercent ?? this.segmentationPercent,
        data: data ?? this.data,
        customParams:
            Mergeable.mergeCustomParams(this.customParams, customParams),
      );
}
