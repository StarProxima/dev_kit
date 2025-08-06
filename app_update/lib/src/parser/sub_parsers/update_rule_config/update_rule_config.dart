import '../../../shared/app_status.dart';
import '../../../shared/update_date.dart';
import '../../../shared/update_locale.dart';
import '../../../shared/update_source.dart';
import '../../../shared/update_version_constraint.dart';
import '../../../shared/update_view_target.dart';

class UpdateRuleConfig<T> {
  final List<AppStatus> appStatuses;
  final List<UpdateLocale> locales;
  final List<UpdateViewTarget> viewTargets;
  final List<UpdateVersionConstraint> versions;
  final List<UpdateSource> sources;
  final UpdateDate date;
  final T data;
  final Map<String, dynamic>? customData;

  const UpdateRuleConfig({
    this.appStatuses = const [AppStatus.any],
    this.locales = const [UpdateLocale.any],
    this.viewTargets = const [UpdateViewTarget.any],
    this.versions = const [UpdateVersionConstraint.any],
    this.sources = const [UpdateSource.any],
    this.date = UpdateDate.any,
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
    required this.data,
    required this.customData,
  });
}
