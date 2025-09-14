import '../../entities/app_status.dart';
import '../../entities/update_locale.dart';
import '../../entities/update_platform.dart';
import '../../entities/update_source.dart';
import '../../entities/update_version_constraint.dart';
import '../../entities/update_view_target.dart';
import '../../utils/mergeable.dart';

class UpdateRuleWhen {
  final List<AppStatus>? appStatusIs;
  final List<UpdateLocale>? localeIs;
  final List<UpdateViewTarget>? viewTargetIs;
  final List<UpdateVersionConstraint>? appVersionIs;
  final List<UpdateSource>? sourceIs;
  final List<UpdatePlatform>? platformIs;
  final Map<String, dynamic>? customParams;

  const UpdateRuleWhen({
    this.appStatusIs,
    this.localeIs,
    this.viewTargetIs,
    this.appVersionIs,
    this.sourceIs,
    this.platformIs,
    this.customParams,
  });

  const UpdateRuleWhen.byRequired({
    required this.appStatusIs,
    required this.localeIs,
    required this.viewTargetIs,
    required this.appVersionIs,
    required this.sourceIs,
    required this.platformIs,
    required this.customParams,
  });

  UpdateRuleWhen copyWith({
    List<AppStatus>? appStatusIs,
    List<UpdateLocale>? localeIs,
    List<UpdateViewTarget>? viewTargetIs,
    List<UpdateVersionConstraint>? appVersionIs,
    List<UpdateSource>? sourceIs,
    List<UpdatePlatform>? platformIs,
    Map<String, dynamic>? customParams,
  }) =>
      UpdateRuleWhen(
        appStatusIs: appStatusIs ?? this.appStatusIs,
        localeIs: localeIs ?? this.localeIs,
        viewTargetIs: viewTargetIs ?? this.viewTargetIs,
        appVersionIs: appVersionIs ?? this.appVersionIs,
        sourceIs: sourceIs ?? this.sourceIs,
        platformIs: platformIs ?? this.platformIs,
        customParams: Mergeable.mergeCustomParams(
          this.customParams,
          customParams,
        ),
      );
}
