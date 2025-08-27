import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:app_update/app_update.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';
import 'package:app_update/app_update.dart';

// Хелперы для создания тестовых данных (общие для всех групп)
ReleaseConfig createRelease({
  required Version version,
  DateTime? date,
  List<ReleaseSourceConfig>? sources,
  List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
  List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
  List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
  Map<String, dynamic>? customData,
}) {
  return ReleaseConfig(
    version: version,
    date: date ?? DateTime(2024),
    sources: sources,
    contentRules: contentRules,
    settingsRules: settingsRules,
    appSettingsRules: appSettingsRules,
    customData: customData,
  );
}

ReleaseSourceConfig createReleaseSource({
  required UpdateSourceName sourceName,
  List<ReleasePlatformConfig>? platforms,
  ReleaseOverrideConfig? releaseOverride,
}) {
  return ReleaseSourceConfig(
    sourceName: sourceName,
    platforms: platforms,
    releaseOverride: releaseOverride,
  );
}

ReleasePlatformConfig createReleasePlatform({
  required UpdatePlatform platformName,
}) {
  return ReleasePlatformConfig(
    platformName: platformName,
  );
}

GlobalSourceConfig createGlobalSource({
  required UpdateSourceName sourceName,
  List<GlobalPlatformConfig>? platforms,
}) {
  return GlobalSourceConfig(
    sourceName: sourceName,
    platforms: platforms,
  );
}

GlobalPlatformConfig createGlobalPlatform({
  required UpdatePlatform platformName,
}) {
  return GlobalPlatformConfig(
    platformName: platformName,
  );
}

UpdateRuleConfig<UpdateContentConfig> createContentRule({
  String? title,
  String? description,
}) {
  return UpdateRuleConfig<UpdateContentConfig>(
    data: UpdateContentConfig(
      title: title,
      description: description,
    ),
  );
}

UpdateRuleConfig<UpdateSettingsConfig> createSettingsRule({
  bool? shouldShow,
}) {
  return UpdateRuleConfig<UpdateSettingsConfig>(
    data: UpdateSettingsConfig(
      shouldShow: shouldShow,
    ),
  );
}

UpdateRuleConfig<UpdateAppSettingsConfig> createAppSettingsRule({
  AppStatus? appStatus,
}) {
  return UpdateRuleConfig<UpdateAppSettingsConfig>(
    data: UpdateAppSettingsConfig(
      appStatus: appStatus,
    ),
  );
}

UpdateConfig createUpdateConfig({
  List<UpdateRuleConfig<UpdateContentConfig>>? contentRules,
  List<UpdateRuleConfig<UpdateSettingsConfig>>? settingsRules,
  List<UpdateRuleConfig<UpdateAppSettingsConfig>>? appSettingsRules,
  List<GlobalSourceConfig>? sources,
  List<ReleaseConfig>? releases,
  Map<String, dynamic>? customData,
}) {
  return UpdateConfig(
    contentRules: contentRules,
    settingsRules: settingsRules,
    appSettingsRules: appSettingsRules,
    sources: sources,
    releases: releases ?? [],
    customData: customData,
  );
}
