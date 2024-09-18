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
import '../parser/models/release_config.dart';
import '../parser/models/release_settings_config.dart';
import '../parser/update_config_parser.dart';
import '../shared/update_platform.dart';

import '../sources/fetchers/source_fetcher.dart';
import '../sources/source.dart';
import 'update_contoller_base.dart';

class UpdateController extends UpdateContollerBase {
  final _asyncPackageInfo = PackageInfo.fromPlatform();
  Completer<UpdateConfig>? _configDataCompleter;

  final UpdateConfigFetcher? _updateConfigFetcher;
  final _parser = const UpdateConfigParser();
  final ReleaseSettingsConfig? _releaseSettings;
  final _linker = const UpdateConfigLinker();
  UpdateLocalizer? _localizer;
  UpdateFinder? _finder;

  final SourceReleaseFetcherCoordinator? _storeFetcherCoordinator;
  final List<Source>? _globalSources;
  final UpdatePlatform _platform;
  final Locale _locale;

  final _availableUpdateStream = StreamController<AppUpdate>();
  final _updateConfigStream = StreamController<UpdateConfig>();

  @override
  Stream<AppUpdate> get availableUpdateStream => _availableUpdateStream.stream;

  @override
  Stream<UpdateConfig> get updateConfigStream => _updateConfigStream.stream;

  UpdateController({
    UpdateConfigFetcher? updateConfigFetcher,
    SourceReleaseFetcherCoordinator? storeFetcherCoordinator,
    ReleaseSettingsConfig? releaseSettings,
    List<Source>? globalSources,
    UpdatePlatform? platform,
    required Locale locale,
  })  : _updateConfigFetcher = updateConfigFetcher,
        _storeFetcherCoordinator = storeFetcherCoordinator,
        _releaseSettings = releaseSettings,
        _globalSources = globalSources,
        _locale = locale,
        _platform = platform ?? UpdatePlatform.current();

  @override
  Future<void> fetch() async {
    _configDataCompleter = Completer();
    final packageInfo = await _asyncPackageInfo;

    final fetcher = _updateConfigFetcher;
    if (fetcher == null) return;
    final rawConfig = await fetcher.fetch();

    // ignore: unused_local_variable
    final config = _parser.parseConfig(rawConfig, isDebug: kDebugMode);

    final releaseConfigsFromStores = <ReleaseConfig>[];
    final sources = _globalSources ?? config.stores ?? [];
    if (_storeFetcherCoordinator != null) {
      for (final store in sources) {
        // TODO поменяй
        final fetcher = await _storeFetcherCoordinator!.fetcherByStore(store);
        final releaseConfig = await fetcher.fetch(source: store, locale: _locale, packageInfo: packageInfo);
        releaseConfigsFromStores.add(releaseConfig);
      }
    }

    final configData = _linker.linkConfigs(
      releaseSettingsConfig: _releaseSettings ?? config.settings,
      releasesConfig: config.releases,
      storesConfig: config.sources,
      customData: config.customData,
    );

    _localizer ??= UpdateLocalizer(appLocale: _locale, packageInfo: packageInfo);
    final updateConfig = _localizer!.localizeConfig(configData);

    _configDataCompleter?.complete(updateConfig);
    final updateData = await findAvailableUpdate();

    _updateConfigStream.add(updateConfig);
    if (updateData != null) _availableUpdateStream.add(updateData);
  }

  @override
  Future<AppUpdate> findUpdate() {
    throw UnimplementedError();
  }

  @override
  Future<AppUpdate?> findAvailableUpdate() async {
    if (_configDataCompleter == null) return null;
    final updateConfig = await _configDataCompleter!.future;
    final packageInfo = await _asyncPackageInfo;

    _finder ??= UpdateFinder(appVersion: Version.parse(packageInfo.version), platform: _platform);
    final latestRelease = _finder!.findAvailableRelease(updateConfig);
    if (latestRelease == null) return null;

    final appName = packageInfo.appName;
    final appVersion = Version.parse(packageInfo.version);
    final updateData = AppUpdate(
      appName: appName,
      appVersion: appVersion,
      appLocale: _locale,
      config: updateConfig,
      availableRelease: latestRelease,
    );

    return updateData;
  }

  @override
  Future<void> launchReleaseStore(Release release) {
    // TODO: implement launchStore
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
