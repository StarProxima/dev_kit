import '../mergeable.dart';
import '../../update_entities/app_status.dart';
import '../../update_entities/update_date.dart';
import '../../update_entities/update_locale.dart';
import '../../update_entities/update_source.dart';
import '../../update_entities/update_version_constraint.dart';
import '../../update_entities/update_view_target.dart';

class UpdateRuleConfig<T extends Mergeable> {
  final List<AppStatus>? appStatuses;
  final List<UpdateLocale>? locales;
  final List<UpdateViewTarget>? viewTargets;
  final List<UpdateVersionConstraint>? versions;
  final List<UpdateSource>? sources;
  final UpdateDate? date;
  final Duration? delay;
  final Duration? rollout;
  final double? segmentationPercent;
  final Map<String, dynamic>? customData;
  final T data;

  const UpdateRuleConfig({
    this.appStatuses,
    this.locales,
    this.viewTargets,
    this.versions,
    this.sources,
    this.date,
    this.delay,
    this.rollout,
    this.segmentationPercent,
    this.customData,
    required this.data,
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
    Map<String, dynamic>? customData,
    T? data,
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
