// ignore_for_file: unused_field

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../builder/models/app_update.dart';
import '../config/models/release_settings_dto.dart';
import '../config/models/store_dto.dart';
import '../config/update_config_parser.dart';
import '../data/models/checker_config.dart';
import '../data/checker_config_parser.dart';
import '../data/models/release.dart';
import '../data/stores/fetchers/store_fetcher.dart';
import '../models/version.dart';
import 'update_config_provider.dart';
import 'update_contoller_base.dart';

class UpdateController extends UpdateContollerBase {
  final _parser = const UpdateConfigParser();

  final _linker = const CheckerConfigLinker();

  final _asyncPackageInfo = PackageInfo.fromPlatform();

  Completer<CheckerConfig>? _configDataCompleter;

  final UpdateConfigProvider? _updateConfigProvider;
  final StoreFetcherCoordinator? _storeFetcherCoordinator;
  final ReleaseSettingsDTO? _releaseSettings;
  final List<StoreDTO>? _stores;

  @override
  Stream<AppUpdate> get availableUpdateStream => throw UnimplementedError();

  UpdateController({
    UpdateConfigProvider? updateConfigProvider,
    StoreFetcherCoordinator? storeFetcherCoordinator,
    ReleaseSettingsDTO? releaseSettings,
    List<StoreDTO>? stores,
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

  Future<Release?> _findLatestRelease() async {
    // ignore: unused_local_variable, avoid-non-null-assertion
    final configData = await _configDataCompleter!.future;
    // ignore: unused_local_variable
    final packageInfo = await _asyncPackageInfo;

    // TODO: implement it
    return configData.releases.lastOrNull;
  }
}
