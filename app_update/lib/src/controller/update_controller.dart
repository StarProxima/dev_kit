// ignore_for_file: unused_field, use_late_for_private_fields_and_variables, avoid-non-null-assertion, prefer-unwrapping-future-or, prefer-moving-to-variable

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../fetcher/update_config_fetcher.dart';
import '../finalizer/models/app_update.dart';
import '../finalizer/models/release.dart';
import '../finalizer/models/update_config.dart';
import '../finalizer/update_finalizer.dart';
import '../finder/update_finder.dart';
import '../linker/models/update_settings_data_container.dart';
import '../linker/models/update_text_data_container.dart';
import '../linker/update_config_linker.dart';
import '../parser/models/release_config.dart';
import '../parser/models/update_config_model.dart';
import '../parser/update_config_parser.dart';
import '../shared/text_translations.dart';
import '../shared/update_platform.dart';
import '../sources/fetchers/source_fetcher.dart';
import '../sources/source.dart';
import '../storage/update_storage.dart';
import '../storage/update_storage_manager.dart';
import '../version_controller/update_version_controller.dart';
import 'exceptions.dart';
import 'update_contoller_base.dart';

class UpdateController extends UpdateControllerBase {
  final _asyncPackageInfo = PackageInfo.fromPlatform();

  final UpdateConfigFetcher? _updateConfigFetcher;
  final _parser = const UpdateConfigParser();
  final UpdateSettingsDataContainer? _updateSettings;
  final UpdateTextDataContainer? _updateText;
  final _linker = const UpdateConfigLinker();

  UpdateVersionController? _versionController;
  UpdateFinalizer? _finalizer;
  final SourceReleaseFetcherCoordinator _sourceFetcherCoordinator;
  UpdateFinder? _finder;

  UpdateStorage? _updateStorage;
  UpdateStorageManager? _updateStorageManager;

  final List<Source>? _globalSources;
  final UpdatePlatform _platform;

  final Source? _targetSource;
  final Source? _defaultSource;

  Completer<UpdateConfigModel>? _updateConfigModelCompleter;
  Completer<List<ReleaseConfig>>? _sourceReleasesConfigFromFetchersCompleter;
  final _availableUpdateStream = StreamController<AppUpdate>();
  final _updateConfigStream = StreamController<UpdateConfig>();

  @override
  Stream<AppUpdate> get availableUpdateStream => _availableUpdateStream.stream;

  @override
  Stream<UpdateConfig> get updateConfigStream => _updateConfigStream.stream;

  UpdateController({
    UpdateConfigFetcher? updateConfigFetcher,
    SourceReleaseFetcherCoordinator? sourceFetcherCoordinator,
    UpdateSettingsDataContainer? updateSettings,
    UpdateTextDataContainer? updateText,
    UpdateStorage? storage,
    // TODO: Нам, поидее, нужно передавать List<GlobalSourceConfig>
    // TODO: Потом сделать, чтобы передавалось GlobalSource без nullable name и config
    List<Source>? globalSources,
    UpdatePlatform? targetPlatform,
    Source? targetSource,
    Source? defaultSource,
  })  : _updateConfigFetcher = updateConfigFetcher,
        _sourceFetcherCoordinator = sourceFetcherCoordinator ?? const SourceReleaseFetcherCoordinator(),
        _updateSettings = updateSettings,
        _updateText = updateText,
        _updateStorage = storage,
        _globalSources = globalSources,
        _targetSource = targetSource,
        _defaultSource = defaultSource,
        _platform = targetPlatform ?? UpdatePlatform.current();

  @override
  Future<void> fetch({
    Locale locale = kAppUpdateDefaultLocale,
  }) async {
    await fetchUpdateConfig();
    await fetchGlobalSourceReleases(locale: locale);
  }

  @override
  Future<void> fetchUpdateConfig() async {
    _updateConfigModelCompleter = Completer();

    final fetcher = _updateConfigFetcher;
    if (fetcher == null) throw const UpdateNotFoundException();
    final rawConfig = await fetcher.fetch();

    final configModel = _parser.parse(rawConfig, isDebug: kDebugMode);

    _updateConfigModelCompleter!.complete(configModel);
  }

  @override
  Future<void> fetchGlobalSourceReleases({
    Locale locale = kAppUpdateDefaultLocale,
  }) async {
    _sourceReleasesConfigFromFetchersCompleter = Completer();

    final packageInfo = await _asyncPackageInfo;
    final releases = <ReleaseConfig>[];
    for (final source in _globalSources ?? []) {
      final fetcher = await _sourceFetcherCoordinator.fetcherBySource(source);
      final releaseFromSource = await fetcher.fetch(source: source, locale: locale, packageInfo: packageInfo);
      if (releaseFromSource != null) releases.add(releaseFromSource);
    }

    _sourceReleasesConfigFromFetchersCompleter!.complete(releases);
  }

  @override
  Future<AppUpdate> findUpdate({
    Locale locale = kAppUpdateDefaultLocale,
  }) async {
    final packageInfo = await _asyncPackageInfo;
    final appVersion = Version.parse(packageInfo.version);
    final updateConfig = await _findUpdateConfig(locale: locale);

    _finder ??= UpdateFinder(appVersion: appVersion, platform: _platform);
    final availableReleasesBySources = _finder!.findAvailableReleasesBySource(releases: updateConfig.releases);

    // TODO сделать больше обобщение метода
    final availableRelease = await _finder!.findAvailableRelease(
      availableReleasesBySources: availableReleasesBySources,
      sources: updateConfig.sources,
      // TODO: Завести типизацию, без стингов
      prioritySourceName: _targetSource?.name,
    );

    final currentReleaseStatus = _versionController!.setStatusByVersion(appVersion);

    final appUpdate = AppUpdate(
      appName: packageInfo.appName,
      appVersion: appVersion,
      config: updateConfig,
      appVersionStatus: currentReleaseStatus,
      release: availableRelease ?? (throw const UpdateNotFoundException()),
    );

    _updateStorage ??= UpdateStorage(await SharedPreferences.getInstance());
    _updateStorageManager ??= UpdateStorageManager(_updateStorage!);

    if (_updateStorageManager!.isSkippedRelease(availableRelease.version)) {
      throw UpdateSkippedException(update: appUpdate);
    }
    if (_updateStorageManager!.isPostponedRelease(availableRelease.version)) {
      throw UpdatePostponedException(update: appUpdate);
    }

    _updateConfigStream.add(updateConfig);
    _availableUpdateStream.add(appUpdate);

    return appUpdate;
  }

  @override
  Future<List<AppUpdate>> findAllAvailableUpdates({
    Locale locale = kAppUpdateDefaultLocale,
  }) async {
    final packageInfo = await _asyncPackageInfo;
    final appVersion = Version.parse(packageInfo.version);
    final updateConfig = await _findUpdateConfig(locale: locale);

    _finder ??= UpdateFinder(appVersion: appVersion, platform: _platform);
    final availableReleasesBySources = _finder!.findAvailableReleasesBySource(releases: updateConfig.releases);

    final currentReleaseStatus = _versionController!.setStatusByVersion(appVersion);

    _updateStorage ??= UpdateStorage(await SharedPreferences.getInstance());
    _updateStorageManager ??= UpdateStorageManager(_updateStorage!);

    final appUpdateList = <AppUpdate>[];
    for (final availableReleaseAndSource in availableReleasesBySources.entries) {
      final availableRelease = availableReleaseAndSource.value;

      if (_updateStorageManager!.isSkippedRelease(availableRelease.version)) {
        continue;
      }
      if (_updateStorageManager!.isPostponedRelease(availableRelease.version)) {
        continue;
      }

      appUpdateList.add(AppUpdate(
        appName: packageInfo.appName,
        appVersion: appVersion,
        config: updateConfig,
        appVersionStatus: currentReleaseStatus,
        release: availableRelease,
      ));
    }

    return appUpdateList;
  }

  @override
  Future<AppUpdate?> tryFindUpdate({
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
  Future<void> launchReleaseSource(Release release) async {
    _updateStorage ??= UpdateStorage(await SharedPreferences.getInstance());
    await _updateStorage?.saveLastSource(release.source.name);

    final url = release.source.url;
    await launchUrl(url);
  }

  @override
  Future<void> postponeRelease({
    required Release release,
    required Duration postponeDuration,
  }) async {
    _updateStorage ??= UpdateStorage(await SharedPreferences.getInstance());

    await _updateStorage?.addPostponedRelease(
      releaseVersion: release.version,
      postponeDuration: postponeDuration,
    );
  }

  @override
  Future<void> skipRelease(Release release) async {
    _updateStorage ??= UpdateStorage(await SharedPreferences.getInstance());

    await _updateStorage?.addSkippedRelease(release.version);
  }

  @override
  Future<void> dispose() async {
    await _updateConfigStream.close();
    await _availableUpdateStream.close();
  }

  Future<UpdateConfig> _findUpdateConfig({
    Locale locale = kAppUpdateDefaultLocale,
  }) async {
    if (_updateConfigModelCompleter == null) await fetchUpdateConfig();
    final configModel = await _updateConfigModelCompleter!.future;

    final packageInfo = await _asyncPackageInfo;
    final appVersion = Version.parse(packageInfo.version);
    final appName = packageInfo.appName;

    if (_sourceReleasesConfigFromFetchersCompleter == null) {
      await fetchGlobalSourceReleases(locale: locale);
    }
    final releasesFromSources = await _sourceReleasesConfigFromFetchersCompleter!.future;

    final releasesData = _linker.linkConfigs(
      globalSettingsConfig: configModel.settings,
      releasesConfig: [...configModel.releases, ...releasesFromSources],
      globalSourcesConfig: configModel.sources,
    );

    final sources = _linker.parseSources(sourcesConfig: configModel.sources ?? []);
    sources.addAll([...?_globalSources]);

    _versionController = UpdateVersionController(configModel.versionSettings);
    final availableReleasesData = _versionController!.filterAvailableReleaseData(releasesData);

    _finalizer ??= UpdateFinalizer(
      appName: appName,
      appVersion: appVersion,
      textContainer: _updateText,
      settingsContainer: _updateSettings,
    );

    final releases = _finalizer!.fializeReleases(availableReleasesData);

    final updateConfig = UpdateConfig(
      sources: sources,
      releases: releases,
      customData: configModel.customData,
    );

    return updateConfig;
  }
}
