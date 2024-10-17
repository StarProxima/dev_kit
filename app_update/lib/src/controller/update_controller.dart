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
import '../parser/models/update_config_model.dart';
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

class UpdateController extends UpdateControllerBase {
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

  Completer<UpdateConfigModel>? _updateConfigModelCompleter;
  Completer<List<Release>>? _sourceReleasesFromFetchersCompleter;
  final _availableUpdateStream = StreamController<AppUpdate>();
  final _updateConfigStream = StreamController<UpdateConfig>();

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

    final configModel = _parser.parseConfig(rawConfig, isDebug: kDebugMode);

    _updateConfigModelCompleter!.complete(configModel);
  }

  @override
  Future<void> fetchGlobalSourceReleases({
    Locale locale = kAppUpdateDefaultLocale,
  }) async {
    _sourceReleasesFromFetchersCompleter = Completer();

    final packageInfo = await _asyncPackageInfo;
    final releases = <Release>[];
    for (final source in _globalSources ?? []) {
      final fetcher = await _sourceFetcherCoordinator!.fetcherBySource(source);
      final releaseFromSource = await fetcher.fetch(source: source, locale: locale, packageInfo: packageInfo);
      releases.add(releaseFromSource);
    }

    _sourceReleasesFromFetchersCompleter!.complete(releases);
  }

  @override
  Future<AppUpdate> findUpdate({
    Locale locale = kAppUpdateDefaultLocale,
  }) async {
    if (_updateConfigModelCompleter == null) await fetchUpdateConfig();
    final configModel = await _updateConfigModelCompleter!.future;

    final packageInfo = await _asyncPackageInfo;
    final appVersion = Version.parse(packageInfo.version);
    final appName = packageInfo.appName;

    final releasesData = _linker.linkConfigs(
      globalSettingsConfig: _releaseSettings ?? configModel.settings,
      releasesConfig: configModel.releases,
      globalSourcesConfig: configModel.sources,
    );

    final sources = _linker.parseSources(sourcesConfig: configModel.sources ?? []);

    _versionController ??= UpdateVersionController(configModel.versionSettings);
    final availableReleasesData = _versionController!.filterAvailableReleaseData(releasesData);

    _localizer ??= UpdateLocalizer(appName: appName, appVersion: appVersion);
    final releases = _localizer!.localizeReleasesData(availableReleasesData);

    _sourceFetcherCoordinator ??= const SourceReleaseFetcherCoordinator();

    if (_sourceReleasesFromFetchersCompleter == null) await fetchGlobalSourceReleases();
    final releasesFromSources = await _sourceReleasesFromFetchersCompleter!.future;
    releases.addAll(releasesFromSources);
    sources.addAll([...?_globalSources]);

    final updateConfig = UpdateConfig(
      sources: sources,
      releases: releases,
      customData: configModel.customData,
    );

    _finder ??= UpdateFinder(appVersion: appVersion, platform: _platform);
    final availableReleasesBySources = _finder!.findAvailableReleasesBySource(releases: releases);

    final availableRelease = await _finder!.findAvailableRelease(
      availableReleasesBySources: availableReleasesBySources,
      sources: sources,
      prioritySourceName: _prioritySourceName,
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
  Future<List<AppUpdate>> findAllAvailableUpdates({
    Locale locale = kAppUpdateDefaultLocale,
  }) {
    // TODO: implement findAllAvailableUpdates
    throw UnimplementedError();
  }

  @override
  Future<void> launchReleaseSource(Release release) async {
    _updateStorage ??= UpdateStorage(await SharedPreferences.getInstance());
    await _updateStorage?.saveLastSource(release.targetSource.name);

    final url = release.targetSource.url;
    await launchUrl(url);
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
