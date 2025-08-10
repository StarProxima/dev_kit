// ignore_for_file: use_late_for_private_fields_and_variables, avoid-non-null-assertion, prefer-unwrapping-future-or

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
import '../parser/sub_parsers/release_config/release_config.dart';
import '../parser/sub_parsers/update_model_config/update_model_config.dart';
import '../parser/update_config_parser.dart';
import '../shared/text_translations.dart';
import '../shared/update_entities/update_platform.dart';
import '../sources/fetchers/source_release_fetcher_coordinator.dart';
import '../sources/release_source.dart';
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
  final UpdateSettingsConfigContainer? _updateSettings;
  final UpdateTextDataContainer? _updateText;
  final _linker = const UpdateConfigLinker();

  UpdateFinalizer? _finalizer;
  final SourceReleaseFetcherCoordinator _sourceFetcherCoordinator;
  UpdateFinder? _finder;

  UpdateStorage? _updateStorage;
  UpdateStorageManager? _updateStorageManager;

  final List<Source>? _globalSources;

  final UpdatePlatform _platform;
  final String? _targetSourceName;
  final String? _defaultSourceName;

  Completer<UpdateConfig?>? _updateConfigModelCompleter;
  Completer<List<ReleaseConfig>>? _sourceReleasesConfigFromFetchersCompleter;
  final _availableUpdateStream = StreamController<UpdateResult>();
  final _updateConfigStream = StreamController<UpdateConfig>();

  @override
  Stream<UpdateResult> get availableUpdateStream => _availableUpdateStream.stream;

  @override
  Stream<UpdateConfig> get updateConfigStream => _updateConfigStream.stream;

  UpdateController({
    UpdateConfigFetcher? updateConfigFetcher,
    SourceReleaseFetcherCoordinator? sourceFetcherCoordinator,
    UpdateSettingsConfigContainer? updateSettings,
    UpdateTextDataContainer? updateText,
    UpdateStorage? storage,
    List<Source>? globalSources,
    UpdatePlatform? targetPlatform,
    String? targetSourceName,
    String? defaultSourceName,
  })  : _updateConfigFetcher = updateConfigFetcher,
        _sourceFetcherCoordinator =
            sourceFetcherCoordinator ?? const SourceReleaseFetcherCoordinator(),
        _updateSettings = updateSettings,
        _updateText = updateText,
        _updateStorage = storage,
        _globalSources = globalSources,
        _targetSourceName = targetSourceName,
        _defaultSourceName = defaultSourceName,
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
    if (fetcher == null) {
      _updateConfigModelCompleter!.complete(null);
    } else {
      final rawConfig = await fetcher.fetch();
      final configModel = _parser.parse(rawConfig, isDebug: kDebugMode);

      _updateConfigModelCompleter!.complete(configModel);
    }
  }

  @override
  Future<void> fetchGlobalSourceReleases({
    Locale locale = kAppUpdateDefaultLocale,
  }) async {
    _sourceReleasesConfigFromFetchersCompleter = Completer();

    final packageInfo = await _asyncPackageInfo;
    final releases = <ReleaseConfig>[];
    for (final source in _globalSources ?? <Source?>[null]) {
      try {
        final fetcher = await _sourceFetcherCoordinator.fetcherBySourceAndPlatform(
            source: source, platform: _platform);
        final releaseFromSource = await fetcher
            .fetch(
              source: source,
              locale: locale,
              packageInfo: packageInfo,
            )
            .onError((_, __) => null);
        if (releaseFromSource != null) releases.add(releaseFromSource);
        // ignore: avoid_catching_errors
      } on UnimplementedError catch (_) {}
    }

    _sourceReleasesConfigFromFetchersCompleter!.complete(releases);
  }

  @override
  Future<UpdateResult> findUpdate({
    Locale locale = kAppUpdateDefaultLocale,
  }) async =>
      (await _findUpdatesFromConfig(isFindUpdateFromOneSource: true, locale: locale)).firstOrNull ??
      (throw const UpdateNotFoundException());

  @override
  Future<List<UpdateResult>> findAllAvailableUpdates({
    Locale locale = kAppUpdateDefaultLocale,
  }) =>
      _findUpdatesFromConfig(isFindUpdateFromOneSource: false, locale: locale);

  @override
  Future<UpdateResult?> tryFindUpdate({
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

  Future<List<UpdateResult>> _findUpdatesFromConfig({
    required bool isFindUpdateFromOneSource,
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

    final globalSourcesConfig = [
      ...?configModel?.sources,
      ...?_globalSources?.map((e) => e.toGlobalSourceConfig())
    ];
    final releasesConfig = [...?configModel?.releases, ...releasesFromSources];

    final releasesData = _linker.linkConfigs(
      globalSettingsConfig: configModel?.settingsRules,
      globalTextConfig: configModel?.contentRules,
      releasesConfig: releasesConfig,
      globalSourcesConfig: globalSourcesConfig,
      platform: _platform,
    );
    final sources = _linker.parseSources(sourcesConfig: globalSourcesConfig);

    _finalizer ??= UpdateFinalizer(
      appName: appName,
      appVersion: appVersion,
      textContainer: _updateText,
      settingsContainer: _updateSettings,
    );

    final releases = _finalizer!.finalizeReleases(releasesData);

    final updateConfig =
        UpdateConfig(sources: sources, releases: releases, customData: configModel?.customData);

    _finder ??= UpdateFinder(appVersion: appVersion, platform: _platform);
    Map<ReleaseSource, Release> availableReleasesBySources = _finder!.findAvailableReleasesBySource(
      releases: updateConfig.releases,
      globalSourcesConfig: globalSourcesConfig,
      versionSettings: configModel?.appStatusRules,
    );

    if (isFindUpdateFromOneSource) {
      final availableRelease = await _finder!.findAvailableRelease(
        availableReleasesBySources: availableReleasesBySources,
        sources: updateConfig.sources,
        // TODO: Завести типизацию, без стингов
        prioritySourceName: _targetSourceName,
        defaultSourceName: _defaultSourceName,
      );

      if (availableRelease == null) throw const UpdateNotFoundException();
      availableReleasesBySources = {availableRelease.source: availableRelease};
    }

    _updateStorage ??= UpdateStorage(await SharedPreferences.getInstance());
    _updateStorageManager ??= UpdateStorageManager(_updateStorage!);

    final appUpdateList = <UpdateResult>[];
    for (final MapEntry(key: source, value: availableRelease)
        in availableReleasesBySources.entries) {
      final globalSource = globalSourcesConfig.where((e) => e.name == source.name).firstOrNull;
      final updateVersionController = UpdateVersionController.fromGlobalSource(
        versionSettingsConfig: configModel?.appStatusRules,
        globalSource: globalSource,
        platform: _platform,
      );

      final currentReleaseStatus = updateVersionController.setStatusByVersion(
        version: appVersion,
      );

      final appUpdate = UpdateResult(
        appName: appName,
        appVersion: appVersion,
        config: updateConfig,
        appVersionStatus: currentReleaseStatus,
        release: availableRelease,
      );

      if (_updateStorageManager!.isSkippedRelease(availableRelease.version)) {
        if (isFindUpdateFromOneSource) throw UpdateSkippedException(update: appUpdate);
        continue;
      }
      if (_updateStorageManager!.isPostponedRelease(availableRelease.version)) {
        if (isFindUpdateFromOneSource) throw UpdatePostponedException(update: appUpdate);
        continue;
      }

      if (isFindUpdateFromOneSource) {
        _updateConfigStream.add(updateConfig);
        _availableUpdateStream.add(appUpdate);
      }

      appUpdateList.add(appUpdate);
    }

    return appUpdateList;
  }
}
