// ignore_for_file: unused_field, use_late_for_private_fields_and_variables, avoid-non-null-assertion

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../fetcher/update_config_fetcher.dart';
import '../finder/update_finder.dart';
import '../linker/update_config_linker.dart';
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
import 'update_contoller_base.dart';

class UpdateController extends UpdateContollerBase {
  final _asyncPackageInfo = PackageInfo.fromPlatform();
  Completer<UpdateConfig>? _configDataCompleter;

  final UpdateConfigFetcher? _updateConfigFetcher;
  final _parser = const UpdateConfigParser();
  final UpdateSettingsConfig? _releaseSettings;
  final _linker = const UpdateConfigLinker();
  UpdateVersionController? _versionController;
  UpdateLocalizer? _localizer;
  UpdateFinder? _finder;

  final SourceReleaseFetcherCoordinator? _sourceFetcherCoordinator;
  final List<Source>? _globaSources;
  final UpdatePlatform _platform;
  final String? _prioritySourceName;
  final Locale _locale;

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
    List<Source>? globalSources,
    UpdatePlatform? platform,
    String? prioritySourceName,
    required Locale locale,
  })  : _updateConfigFetcher = updateConfigFetcher,
        _sourceFetcherCoordinator = sourceFetcherCoordinator,
        _releaseSettings = releaseSettings,
        _globaSources = globalSources,
        _prioritySourceName = prioritySourceName,
        _locale = locale,
        _platform = platform ?? UpdatePlatform.current();

  @override
  Future<void> fetch() async {
    _configDataCompleter = Completer();
    final packageInfo = await _asyncPackageInfo;

    final fetcher = _updateConfigFetcher;
    if (fetcher == null) return;
    final rawConfig = await fetcher.fetch();

    final configModel = _parser.parseConfig(rawConfig, isDebug: kDebugMode);

    final releasesData = _linker.linkConfigs(
      globalSettingsConfig: _releaseSettings ?? configModel.settings,
      releasesConfig: configModel.releases,
      globalSourcesConfig: configModel.sources,
    );

    // final releaseConfigsFromSources = <ReleaseConfig>[];
    // final sources = _globalSources ?? config.sources ?? [];
    // if (_sourceFetcherCoordinator != null) {
    //   for (final source in sources) {
    //     // TODO фичу фетчера сурсов сделай. Она добавляет к списку ещё
    //     final fetcher = await _sourceFetcherCoordinator!.fetcherBySource(source);
    //     final releaseConfig = await fetcher.fetch(source: source, locale: _locale, packageInfo: packageInfo);
    //     releaseConfigsFromSources.add(releaseConfig);
    //   }
    // }

    _versionController ??= UpdateVersionController(configModel.versionSettings);
    final releasesDataWithStatus = _versionController!.setStatuses(releasesData);

    _localizer ??= UpdateLocalizer(appLocale: _locale, packageInfo: packageInfo);
    final releases = _localizer!.localizeReleasesData(releasesDataWithStatus);

    _finder ??= UpdateFinder(appVersion: Version.parse(packageInfo.version), platform: _platform);
    // TODO здесь нужно возращать сурсы только для конкретного источника
    final availableReleasesBySources = _finder!.findAvailableReleasesBySource(releases);

    final sources = availableReleasesBySources.keys.toList();
    final availableReleasesFromAllSources = availableReleasesBySources.values.whereType<Release>().toList();
    final updateConfig = UpdateConfig(
      sources: sources,
      releases: releases,
      customData: configModel.customData,
    );

    final availableReleaseForCurrentSource = await _finder!.findAvailableRelease(
      availableReleasesBySources: availableReleasesBySources,
      prioritySourceName: _prioritySourceName,
    );

    // final updateData = await findAvailableUpdate();
    // TODO _configDataCompleter?.complete(releases);

    _updateConfigStream.add(updateConfig);
    if (availableReleaseForCurrentSource != null) {
      final appUpdate = AppUpdate(
        appName: packageInfo.appName,
        appVersion: Version.parse(packageInfo.version),
        appLocale: _locale,
        config: updateConfig,
        currentRelease: availableReleaseForCurrentSource, // TODO нынешний релиз
        availableRelease: availableReleaseForCurrentSource,
        availableReleasesFromAllSources: availableReleasesFromAllSources,
      );
      _availableUpdateStream.add(appUpdate);
    }
  }

  @override
  Future<AppUpdate> findUpdate() {
    throw UnimplementedError();
  }

  @override
  Future<AppUpdate?> findAvailableUpdate() async {
    throw UnimplementedError();
    // if (_configDataCompleter == null) return null;
    // final updateConfig = await _configDataCompleter!.future;
    // final packageInfo = await _asyncPackageInfo;

    // _finder ??= UpdateFinder(appVersion: Version.parse(packageInfo.version), platform: _platform);
    // final latestRelease = _finder!.findAvailableReleasesFromAllSources(updateConfig);
    // if (latestRelease == null) return null;

    // final appName = packageInfo.appName;
    // final appVersion = Version.parse(packageInfo.version);
    // final updateData = AppUpdate(
    //   appName: appName,
    //   appVersion: appVersion,
    //   appLocale: _locale,
    //   config: updateConfig,
    //   availableRelease: latestRelease,
    // );

    // return updateData;
  }

  @override
  Future<void> launchReleaseSource(Release release) {
    // TODO: implement launchSource
    throw UnimplementedError();
  }

  @override
  Future<void> postponeRelease(Release release) {
    // TODO: implement postponeRelease
    throw UnimplementedError();
  }

  @override
  Future<void> skipRelease(Release release) {
    // TODO: implement skipRelease
    throw UnimplementedError();
  }

  @override
  Future<UpdateConfig> getCurrentUpdateConfig() {
    // TODO: implement getUpdateConfig
    throw UnimplementedError();
  }
}
