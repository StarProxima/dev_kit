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
  double segmentationPointer = 0.0,
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
    localVersion: Version.parse(version),
    displayTarget: target,
    appStatus: appStatus ?? AppStatus.any,
    locale: locale ?? const UpdateLocale(Locale('ru')),
    currentDate: currentDate ?? DateTime(2024, 10, 20, 12),
    localReleaseDate: localReleaseDate,
    updateReleaseDate: updateReleaseDate,
    appUpdateDate: appUpdateDate,
    appInstallDate: appInstallDate,
    segmentationPointer: segmentationPointer,
    rolloutPointer: rolloutPointer,
    appName: appName,
    appPackageName: appPackageName,
    customData: custom,
  );
}

/// Создает UpdateRuleConfig для тестов с настраиваемыми параметрами.
UpdateRuleConfig<UpdateContentConfig> createTestRule({
  List<UpdateViewTarget> targets = const [UpdateViewTarget.any],
  List<UpdateLocale> locales = const [UpdateLocale.any],
  List<UpdateSource> sources = const [UpdateSource.any],
  List<UpdateVersionConstraint> versions = const [UpdateVersionConstraint.any],
  List<AppStatus> statuses = const [AppStatus.any],
  UpdateDate date = UpdateDate.any,
  Duration? delay,
  Duration? rollout,
  double? segmentation,
  String? title,
  String? description,
  Map<String, dynamic>? custom,
}) {
  return UpdateRuleConfig<UpdateContentConfig>.byRequired(
    appStatusIs: statuses,
    localeIs: locales,
    viewTargetIs: targets,
    versionIs: versions,
    sourceIs: sources,
    date: date,
    delay: delay,
    rollout: rollout,
    segmentationPercent: segmentation,
    data: UpdateContentConfig(
      title: title,
      description: description,
    ),
    customData: custom,
  );
}
