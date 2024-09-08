// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../builder/models/app_update.dart';
import '../config/models/release_settings_config.dart';
import '../config/models/store_config.dart';
import '../config/update_config_parser.dart';
import '../linker/models/release_data.dart';
import '../linker/models/update_config_data.dart';
import '../linker/update_config_linker.dart';
import '../models/version.dart';
import '../stores/fetchers/store_fetcher.dart';
import 'update_config_provider.dart';
import 'update_contoller_base.dart';

class UpdateController extends UpdateContollerBase {
  final _parser = const UpdateConfigParser();

  final _linker = const UpdateConfigLinker();

  final _asyncPackageInfo = PackageInfo.fromPlatform();

  Completer<UpdateConfigData>? _configDataCompleter;

  final UpdateConfigProvider? _updateConfigProvider;
  final StoreFetcherCoordinator? _storeFetcherCoordinator;
  final ReleaseSettingsConfig? _releaseSettings;
  final List<StoreConfig>? _stores;

  @override
  Stream<AppUpdate> get availableUpdateStream => throw UnimplementedError();

  UpdateController({
    UpdateConfigProvider? updateConfigProvider,
    StoreFetcherCoordinator? storeFetcherCoordinator,
    ReleaseSettingsConfig? releaseSettings,
    List<StoreConfig>? stores,
  })  : _updateConfigProvider = updateConfigProvider,
        _storeFetcherCoordinator = storeFetcherCoordinator,
        _releaseSettings = releaseSettings,
        _stores = stores;

  @override
  Future<void> fetch() async {
    _configDataCompleter = Completer();

    final provider = _updateConfigProvider;
    if (provider == null) return;

    final rawConfig = await provider.fetch();

    final config = _parser.parseConfig(rawConfig, isDebug: kDebugMode);

    final configData = _linker.parseFromDTO(config);

    // TODO: Process with localizaton and interpolation

    _configDataCompleter?.complete(configData);

    // final updateData = await findAvailableUpdate();

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

    // ignore: avoid-non-null-assertion
    final configData = await _configDataCompleter!.future;
    final packageInfo = await _asyncPackageInfo;

    final appName = packageInfo.appName;
    final appVersion = Version.parse(packageInfo.version);

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
  Future<void> launchReleaseStore(ReleaseData release) {
    // TODO: implement launchStore
    throw UnimplementedError();
  }

  @override
  Future<void> postponeRelease(ReleaseData release) {
    // TODO: implement postponeRelease
    throw UnimplementedError();
  }

  @override
  Future<void> skipRelease(ReleaseData release) {
    // TODO: implement skipRelease
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
