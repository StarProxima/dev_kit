// ignore_for_file: unused_field, use_late_for_private_fields_and_variables, avoid-non-null-assertion, prefer-unwrapping-future-or, prefer-moving-to-variable

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';

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

  final _availableUpdateStream = StreamController<AppUpdate>();
  final _updateConfigStream = StreamController<UpdateConfig>();
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
    // TODO убрать бы локаль по хорошему
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
    final appVersion = Version.parse(packageInfo.version);

    final fetcher = _updateConfigFetcher;
    if (fetcher == null) throw const UpdateNotFoundException();
    final rawConfig = await fetcher.fetch();

    final configModel = _parser.parseConfig(rawConfig, isDebug: kDebugMode);

    final releasesData = _linker.linkConfigs(
      globalSettingsConfig: _releaseSettings ?? configModel.settings,
      releasesConfig: configModel.releases,
      globalSourcesConfig: configModel.sources,
    );

    final sources = _linker.parseSources(sourcesConfig: configModel.sources ?? []);

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
    sources.addAll(globalSources);

    final updateConfig = UpdateConfig(
      sources: sources,
      releases: releases,
      customData: configModel.customData,
    );

    _finder ??= UpdateFinder(appVersion: appVersion, platform: _platform);
    final availableReleasesBySources = _finder!.findAvailableReleasesBySource(releases: releases);

    final availableReleasesFromAllSources = availableReleasesBySources.values.toList();

    final availableRelease = await _finder!.findAvailableRelease(
      availableReleasesBySources: availableReleasesBySources,
      sources: sources,
      prioritySourceName: _prioritySourceName,
    );

    final currentReleaseStatus = _versionController!.setStatusByVersion(appVersion);

    final appUpdate = AppUpdate(
      appName: packageInfo.appName,
      appVersion: Version.parse(packageInfo.version),
      appLocale: _locale,
      config: updateConfig,
      currentReleaseStatus: currentReleaseStatus,
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

  // TODO переписать
  @override
  Future<void> fetch() async {
    try {
      await findUpdate();
      // ignore: empty_catches
    } on UpdateException {}
  }

  @override
  Future<AppUpdate?> getAvailableAppUpdate() async {
    if (_lastAppUpdate == null) await fetch();

    return _lastAppUpdate;
  }

  @override
  Future<UpdateConfig?> getAvailableUpdateConfig() async {
    if (_lastUpdateConfig == null) await fetch();

    return _lastUpdateConfig;
  }

  @override
  Future<void> launchReleaseSource(Release release) async {
    LocalDataService.saveLastSource(release.targetSource.name);

    final url = release.targetSource.url;
    await launchUrl(url);
    // TODO всё?
  }

  @override
  Future<void> postponeRelease({required Release release, required Duration postponeDuration}) async {
    // передаём postponeDuration так как в этой функции не получится определить статус релиза и карточки
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


/* TODO
-Серёга на LocalDataService
-Фетчеры не готовы
-Тудушки по коду
-Релиз ноты
-Сделать все сурсы через энамы
-Все хэндлеры
-Тесты пофиксить


*/