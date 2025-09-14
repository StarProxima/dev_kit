// ignore_for_file: prefer-static-class, avoid-long-parameter-list

import 'dart:ui';

import 'package:app_update/app_update.dart';
import 'package:pub_semver/pub_semver.dart';

/// Создает UpdateSearchData для тестов с настраиваемыми параметрами.
UpdateSearchData createTestSearchData({
  UpdateViewTarget target = UpdateViewTarget.card,
  UpdateLocale? locale,
  List<UpdateSource>? sources,
  String version = '1.0.0',
  String appName = 'appName',
  String appPackageName = 'appPackageName',
  AppStatus? appStatus,
  UpdatePlatform? platform,
  DateTime? currentDate,
  DateTime? localReleaseDate,
  DateTime? updateReleaseDate,
  DateTime? appUpdateDate,
  DateTime? appInstallDate,
  double userSegmentationPointer = 0.0,
  double rolloutPointer = 0.0,
  DateTime? customAppInstallDate,
  Map<String, dynamic>? custom,
}) {
  if (customAppInstallDate != null) {
    custom = {...?custom, 'app_install_date': customAppInstallDate};
  }

  return UpdateSearchData(
    platform: platform ?? UpdatePlatform.android,
    sources: sources ?? const [UpdateSource.googlePlay],
    appVersion: Version.parse(version),
    displayTarget: target,
    appStatus: appStatus ?? AppStatus.any,
    locale: locale ?? const UpdateLocale(Locale('ru')),
    currentDate: currentDate ?? DateTime(2024, 10, 20, 12),
    localReleaseDate: localReleaseDate,
    updateReleaseDate: updateReleaseDate,
    appUpdateDate: appUpdateDate,
    appInstallDate: appInstallDate,
    userSegmentationPointer: userSegmentationPointer,
    rolloutPointer: rolloutPointer,
    appName: appName,
    appPackageName: appPackageName,
    customParams: custom,
  );
}

/// Создает UpdateRuleConfig для тестов с настраиваемыми параметрами.
UpdateRuleConfig<UpdateContentConfig> createTestRule({
  List<UpdateViewTarget> targets = const [UpdateViewTarget.any],
  List<UpdateLocale> locales = const [UpdateLocale.any],
  List<UpdateSource> sources = const [UpdateSource.any],
  List<UpdatePlatform> platforms = const [UpdatePlatform.any],
  List<UpdateVersionConstraint> versions = const [UpdateVersionConstraint.any],
  List<AppStatus> statuses = const [AppStatus.any],
  UpdateDate date = UpdateDate.any,
  Duration? delay,
  Duration? rollout,
  double? segmentation,
  String? title,
  String? description,
  Map<String, dynamic>? custom,
  Map<String, dynamic>? whenCustom,
  Map<String, dynamic>? rolloutCustom,
}) {
  // Разделяем legacy custom params по назначению
  Map<String, dynamic>? whenParams = whenCustom;
  Map<String, dynamic>? rolloutParams = rolloutCustom;

  if (custom != null && (whenCustom == null || rolloutCustom == null)) {
    // Автоматически разделяем старые custom params
    final whenEntries = custom.entries.where((e) => e.key.endsWith('_is'));
    final rolloutEntries = custom.entries.where((e) => !e.key.endsWith('_is'));

    whenParams ??= Map.fromEntries(whenEntries);
    rolloutParams ??= Map.fromEntries(rolloutEntries);
  }

  return UpdateRuleConfig<UpdateContentConfig>(
    when: UpdateRuleWhen(
      appStatusIs: statuses,
      localeIs: locales,
      viewTargetIs: targets,
      appVersionIs: versions,
      sourceIs: sources,
      platformIs: platforms,
      customParams: whenParams?.isNotEmpty == true ? whenParams : null,
    ),
    rollout: UpdateRuleRollout(
      date: date,
      delay: delay,
      gradualRolloutDuration: rollout,
      userSegmentationPercent: segmentation,
      customParams: rolloutParams?.isNotEmpty == true ? rolloutParams : null,
    ),
    data: UpdateContentConfig(
      title: title,
      description: description,
    ),
  );
}
