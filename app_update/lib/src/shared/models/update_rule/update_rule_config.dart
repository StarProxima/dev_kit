import '../../mergeable.dart';
import '../../update_entities/app_status.dart';
import '../../update_entities/update_date.dart';
import '../../update_entities/update_locale.dart';
import '../../update_entities/update_source.dart';
import '../../update_entities/update_version_constraint.dart';
import '../../update_entities/update_view_target.dart';

class UpdateRuleConfig<T> {
  final List<AppStatus>? appStatuses;
  final List<UpdateLocale>? locales;
  final List<UpdateViewTarget>? viewTargets;
  final List<UpdateVersionConstraint>? versions;
  final List<UpdateSource>? sources;
  final UpdateDate? date;
  final Duration? delay;
  final Duration? rollout;
  final double? segmentationPercent;
  final T data;
  final Map<String, dynamic>? customData;

  const UpdateRuleConfig({
    this.appStatuses = const [AppStatus.any],
    this.locales = const [UpdateLocale.any],
    this.viewTargets = const [UpdateViewTarget.any],
    this.versions = const [UpdateVersionConstraint.any],
    this.sources = const [UpdateSource.any],
    this.date = UpdateDate.any,
    this.delay,
    this.rollout,
    this.segmentationPercent,
    required this.data,
    this.customData,
  });

  const UpdateRuleConfig.byRequired({
    required this.appStatuses,
    required this.locales,
    required this.viewTargets,
    required this.versions,
    required this.sources,
    required this.date,
    required this.delay,
    required this.rollout,
    required this.segmentationPercent,
    required this.data,
    required this.customData,
  });

  UpdateRuleConfig<T> copyWith({
    List<AppStatus>? appStatuses,
    List<UpdateLocale>? locales,
    List<UpdateViewTarget>? viewTargets,
    List<UpdateVersionConstraint>? versions,
    List<UpdateSource>? sources,
    UpdateDate? date,
    Duration? delay,
    Duration? rollout,
    double? segmentationPercent,
    T? data,
    Map<String, dynamic>? customData,
  }) =>
      UpdateRuleConfig.byRequired(
        appStatuses: appStatuses ?? this.appStatuses,
        locales: locales ?? this.locales,
        viewTargets: viewTargets ?? this.viewTargets,
        versions: versions ?? this.versions,
        sources: sources ?? this.sources,
        date: date ?? this.date,
        delay: delay ?? this.delay,
        rollout: rollout ?? this.rollout,
        segmentationPercent: segmentationPercent ?? this.segmentationPercent,
        data: data ?? this.data,
        customData: Mergeable.mergeCustomData(this.customData, customData),
      );
}
