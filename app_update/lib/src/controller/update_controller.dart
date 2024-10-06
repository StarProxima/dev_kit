// ignore_for_file: unused_field, use_late_for_private_fields_and_variables, avoid-non-null-assertion, prefer-unwrapping-future-or, prefer-moving-to-variable

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../fetcher/update_config_fetcher.dart';
import '../finder/update_finder.dart';
import '../linker/update_config_linker.dart';
import '../localizer/models/app_update.dart';
import '../localizer/models/release.dart';
import '../localizer/models/update_config.dart';
import '../localizer/update_localizer.dart';
import '../parser/update_config_parser.dart';
import '../shared/text_translations.dart';
import '../shared/update_platform.dart';
import '../shared/update_status_wrapper.dart';
import '../sources/fetchers/source_fetcher.dart';
import '../sources/source.dart';
import '../storage/update_storage.dart';
import '../storage/update_storage_manager.dart';
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

  UpdateStorage? _updateStorage;
  UpdateStorageManager? _updateStorageManager;

  final List<Source>? _globalSources;
  final UpdatePlatform _platform;
  final String? _prioritySourceName;
  // final Locale _locale;

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
    UpdateStorage? storage,
    List<Source>? globalSources,
    UpdatePlatform? platform,
    String? prioritySourceName,
  })  : _updateConfigFetcher = updateConfigFetcher,
        _sourceFetcherCoordinator = sourceFetcherCoordinator,
        _releaseSettings = releaseSettings,
        _updateStorage = storage,
        _globalSources = globalSources,
        _prioritySourceName = prioritySourceName,
        _platform = platform ?? UpdatePlatform.current();

  @override
  Future<AppUpdate> findUpdate({
    Locale locale = kAppUpdateDefaultLocale,
  }) async {
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
    final availableReleasesData = _versionController!.filterAvailableReleaseData(releasesData);

    _localizer ??= UpdateLocalizer(packageInfo: packageInfo);
    final releases = _localizer!.localizeReleasesData(availableReleasesData);

    _sourceFetcherCoordinator ??= const SourceReleaseFetcherCoordinator();
    final globalSources = _globalSources ?? [];
    for (final source in globalSources) {
      final fetcher = await _sourceFetcherCoordinator!.fetcherBySource(source);
      final releaseConfig = await fetcher.fetch(source: source, locale: locale, packageInfo: packageInfo);
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
      config: updateConfig,
      appVersionStatus: currentReleaseStatus,
      availableRelease: availableRelease,
      availableReleasesFromAllSources: availableReleasesFromAllSources,
    );

    _updateStorage ??= UpdateStorage(await SharedPreferences.getInstance());
    _updateStorageManager ??= UpdateStorageManager(_updateStorage!);

    if (availableRelease != null) {
      if (_updateStorageManager!.isSkippedRelease(availableRelease.version)) {
        throw UpdateSkippedException(update: appUpdate);
      }
      if (_updateStorageManager!.isPostponedRelease(availableRelease.version)) {
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
  Future<AppUpdate?> getAvailableAppUpdate({
    Locale locale = kAppUpdateDefaultLocale,
  }) async {
    try {
      final appUpdate = await findUpdate(locale: locale);

      return appUpdate;
    } on UpdateException catch (_) {
      return null;
    }
  }

  @override
  Future<UpdateConfig?> getAvailableUpdateConfig() async {
    if (_lastUpdateConfig == null) await fetch();

    return _lastUpdateConfig;
  }

  @override
  Future<void> launchReleaseSource(Release release) async {
    _updateStorage ??= UpdateStorage(await SharedPreferences.getInstance());
    await _updateStorage?.saveLastSource(release.targetSource.name);

    final url = release.targetSource.url;
    await launchUrl(url);
    // TODO всё?
  }

  @override
  Future<void> postponeRelease({
    required Release release,
    required Duration postponeDuration,
  }) async {
    _updateStorage ??= UpdateStorage(await SharedPreferences.getInstance());

    // передаём postponeDuration так как в этой функции не получится определить статус релиза и карточки
    // TODO: Почему? Статус можно определить можно из Release, а UpdateAlertType передавать в метод из ui
    await _updateStorage?.addPostponedRelease(
      releaseVersion: release.version,
      postponeDuration: postponeDuration,
    );
  }

  @override
  Future<void> skipRelease(Release release) async {
    // TODO: Подумать вообще над инициализацией полей в контроллере, мб это делать всё в одном месте
    _updateStorage ??= UpdateStorage(await SharedPreferences.getInstance());

    await _updateStorage?.addSkippedRelease(release.version);
  }

  @override
  Future<void> dispose() async {
    await _updateConfigStream.close();
    await _availableUpdateStream.close();
  }
}
