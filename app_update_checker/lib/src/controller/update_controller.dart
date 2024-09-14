// ignore_for_file: unused_field, use_late_for_private_fields_and_variables

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../fetcher/update_config_fetcher.dart';
import '../finder/update_finder.dart';
import '../linker/models/release_data.dart';
import '../linker/models/update_config_data.dart';
import '../linker/update_config_linker.dart';
import '../localizer/models/app_update.dart';
import '../localizer/models/release.dart';
import '../localizer/models/update_config.dart';
import '../parser/models/release_settings_config.dart';
import '../parser/models/store_config.dart';
import '../parser/update_config_parser.dart';
import '../shared/update_platform.dart';

import '../stores/fetchers/store_fetcher.dart';
import 'update_contoller_base.dart';

// TODO: Тут хуевасто всё написано, т.к. api менялся, лучше с нуля
class UpdateController extends UpdateContollerBase {
  final _asyncPackageInfo = PackageInfo.fromPlatform();
  Completer<UpdateConfigData>? _configDataCompleter;

  final UpdateConfigFetcher? _updateConfigFetcher;
  final _parser = const UpdateConfigParser();
  final ReleaseSettingsConfig? _releaseSettings;
  final _linker = const UpdateConfigLinker();
  UpdateFinder? _finder;
  final StoreFetcherCoordinator? _storeFetcherCoordinator;
  final UpdatePlatform _platform;
  final List<StoreConfig>? _stores;

  @override
  Stream<AppUpdate> get availableUpdateStream => throw UnimplementedError();

  @override
  Stream<UpdateConfig> get updateConfigStream => throw UnimplementedError();

  UpdateController({
    UpdateConfigFetcher? updateConfigFetcher,
    StoreFetcherCoordinator? storeFetcherCoordinator,
    ReleaseSettingsConfig? releaseSettings,
    List<StoreConfig>? stores,
    UpdatePlatform? platform,
  })  : _updateConfigFetcher = updateConfigFetcher,
        _storeFetcherCoordinator = storeFetcherCoordinator,
        _releaseSettings = releaseSettings,
        _stores = stores,
        _platform = platform ?? UpdatePlatform.current();

  @override
  Future<void> fetch() async {
    _configDataCompleter = Completer();

    final fetcher = _updateConfigFetcher;
    if (fetcher == null) return;
    final rawConfig = await fetcher.fetch();

    // ignore: unused_local_variable
    final config = _parser.parseConfig(rawConfig, isDebug: kDebugMode);

    final configData = _linker.linkConfigs(
      releaseSettingsConfig: _releaseSettings ?? config.releaseSettings,
      releasesConfig: config.releases,
      storesConfig: config.stores,
      customData: config.customData,
    );

    //TODO где знаюзать storeFetcherCoordinator? Откуда брать Store?

    // _configDataCompleter?.complete(configData);
    // TODO дальше...
    final packageInfo = await _asyncPackageInfo;
    _finder ??= UpdateFinder(appVersion: Version.parse(packageInfo.version), platform: _platform);

    final updateData = await findAvailableUpdate();

    // if (updateData == null) return;

    throw UnimplementedError();
  }

  @override
  Future<AppUpdate> findUpdate() {
    throw UnimplementedError();
  }

  @override
  Future<AppUpdate?> findAvailableUpdate() async {
    final latestRelease = await _findLatestRelease();

    if (latestRelease == null) return null;

    // final configData = await _configDataCompleter!.future;
    // final packageInfo = await _asyncPackageInfo;

    // final appName = packageInfo.appName;
    // final appVersion = Version.parse(packageInfo.version);

    throw UnimplementedError();

    // final updateData = AppUpdate(
    //   appName: appName,
    //   appLocale: const Locale('en'),
    //   appVersion: appVersion,
    //   config: configData,
    //   availableRelease: ,
    // );

    // return updateData;
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

  Future<ReleaseData?> _findLatestRelease() async {
    // ignore: unused_local_variable, avoid-non-null-assertion
    final configData = await _configDataCompleter!.future;
    // ignore: unused_local_variable
    final packageInfo = await _asyncPackageInfo;

    // TODO: implement it
    return configData.releases.lastOrNull;
  }
}
