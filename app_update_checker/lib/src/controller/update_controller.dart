// ignore_for_file: unused_field, use_late_for_private_fields_and_variables, avoid-non-null-assertion, prefer-unwrapping-future-or, prefer-moving-to-variable

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../fetcher/update_config_fetcher.dart';
import '../finder/update_finder.dart';
import '../linker/update_config_linker.dart';
import '../local_data_service/local_data_service.dart';
import '../localizer/models/app_update.dart';
import '../localizer/models/release.dart';
import '../localizer/models/update_config.dart';
import '../localizer/update_localizer.dart';
import '../parser/update_config_parser.dart';
import '../shared/update_platform.dart';

import '../shared/update_status_wrapper.dart';
import '../sources/fetchers/source_fetcher.dart';
import '../sources/source.dart';
import '../version_controller/update_version_controller.dart';
import 'exceptions.dart';
import 'update_contoller_base.dart';

class UpdateController extends UpdateContollerBase {
  final _asyncPackageInfo = PackageInfo.fromPlatform();

  final UpdateConfigFetcher? _updateConfigFetcher;
  final _parser = const UpdateConfigParser();
  final UpdateSettingsConfig? _releaseSettings;
  final _linker = const UpdateConfigLinker();
  UpdateVersionController? _versionController;
  UpdateLocalizer? _localizer;
  SourceReleaseFetcherCoordinator? _sourceFetcherCoordinator;
  UpdateFinder? _finder;

  final List<Source>? _globalSources;
  final UpdatePlatform _platform;
  final String? _prioritySourceName;
  final Locale _locale;

  final _availableUpdateStream = StreamController<AppUpdate>.broadcast();
  final _updateConfigStream = StreamController<UpdateConfig>.broadcast();
  AppUpdate? _lastAppUpdate;
  UpdateConfig? _lastUpdateConfig;

  @override
  Stream<AppUpdate> get availableUpdateStream => _availableUpdateStream.stream;

  @override
  Stream<UpdateConfig> get updateConfigStream => _updateConfigStream.stream;

  UpdateController({
    UpdateConfigFetcher? updateConfigFetcher,
    SourceReleaseFetcherCoordinator? sourceFetcherCoordinator,
    UpdateSettingsConfig? releaseSettings,
    List<Source>? globalSources,
    UpdatePlatform? platform,
    String? prioritySourceName,
    required Locale locale,
  })  : _updateConfigFetcher = updateConfigFetcher,
        _sourceFetcherCoordinator = sourceFetcherCoordinator,
        _releaseSettings = releaseSettings,
        _globalSources = globalSources,
        _prioritySourceName = prioritySourceName,
        _locale = locale,
        _platform = platform ?? UpdatePlatform.current();

  @override
  Future<AppUpdate> findUpdate() async {
    await LocalDataService.init();
    final packageInfo = await _asyncPackageInfo;

    final fetcher = _updateConfigFetcher;
    if (fetcher == null) throw const UpdateNotFoundException();
    final rawConfig = await fetcher.fetch();

    final configModel = _parser.parseConfig(rawConfig, isDebug: kDebugMode);

    final releasesData = _linker.linkConfigs(
      globalSettingsConfig: _releaseSettings ?? configModel.settings,
      releasesConfig: configModel.releases,
      globalSourcesConfig: configModel.sources,
    );

    _versionController ??= UpdateVersionController(configModel.versionSettings);
    final releasesDataWithStatus = _versionController!.setStatuses(releasesData);

    _localizer ??= UpdateLocalizer(appLocale: _locale, packageInfo: packageInfo);
    final releases = _localizer!.localizeReleasesData(releasesDataWithStatus);

    _sourceFetcherCoordinator ??= const SourceReleaseFetcherCoordinator();
    final globalSources = _globalSources ?? [];
    for (final source in globalSources) {
      final fetcher = await _sourceFetcherCoordinator!.fetcherBySource(source);
      final releaseConfig = await fetcher.fetch(source: source, locale: _locale, packageInfo: packageInfo);
      releases.add(releaseConfig);
    }

    _finder ??= UpdateFinder(appVersion: Version.parse(packageInfo.version), platform: _platform);
    final availableReleasesBySources = _finder!.findAvailableReleasesBySource(releases: releases);

    final availableReleasesFromAllSources = availableReleasesBySources.values.whereType<Release>().toList();
    final availableRelease = await _finder!.findAvailableRelease(
      availableReleasesBySources: availableReleasesBySources,
      prioritySourceName: _prioritySourceName,
    );

    final currentRelease = await _finder!.findCurrentRelease(releases: releases);

    final updateConfig = UpdateConfig(
      sources: availableReleasesBySources.keys.toList(),
      releases: releases,
      customData: configModel.customData,
    );

    final appUpdate = AppUpdate(
      appName: packageInfo.appName,
      appVersion: Version.parse(packageInfo.version),
      appLocale: _locale,
      config: updateConfig,
      currentRelease: currentRelease,
      availableRelease: availableRelease,
      availableReleasesFromAllSources: availableReleasesFromAllSources,
    );

    if (availableRelease != null) {
      if (LocalDataService.isSkipedRelease(availableRelease.version.toString())) {
        throw UpdateSkippedException(update: appUpdate);
      }
      if (LocalDataService.isPostponedRelease(availableRelease.version.toString())) {
        throw UpdatePostponedException(update: appUpdate);
      }
    }

    _lastUpdateConfig = updateConfig;
    _updateConfigStream.add(updateConfig);
    _lastAppUpdate = appUpdate;
    _availableUpdateStream.add(appUpdate);

    return appUpdate;
  }

  @override
  Future<void> fetch() async {
    try {
      await findUpdate();
      // ignore: empty_catches
    } on UpdateException {}
  }

  @override
  Future<AppUpdate?> getAvailableAppUpdate() async {
    if (_lastAppUpdate == null) {
      await fetch();

      return _lastAppUpdate;
    }

    return _lastAppUpdate;
  }

  @override
  Future<UpdateConfig?> getAvailableUpdateConfig() async {
    if (_lastUpdateConfig == null) {
      await fetch();

      return _lastUpdateConfig;
    }

    return _lastUpdateConfig;
  }

  @override
  Future<void> launchReleaseSource(Release release) {
    LocalDataService.saveLastSource(release.targetSource.name);
    // TODO: implement launchSource
    throw UnimplementedError();
  }

  @override
  Future<void> postponeRelease({required Release release, required Duration postponeDuration}) async {
    // передаём postponeDuration так как в этой функции не получится определить тип релиза и карточки
    LocalDataService.addPostponedRelease(
      releaseVersion: release.version.toString(),
      postponeDuration: postponeDuration,
    );
  }

  @override
  Future<void> skipRelease(Release release) async {
    LocalDataService.addSkippedRelease(release.version.toString());
  }

  @override
  Future<void> dispose() async {
    await _updateConfigStream.close();
    await _availableUpdateStream.close();
  }
}
