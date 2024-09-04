// ignore_for_file: unused_field

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/dto/models/release_settings_dto.dart';
import '../config/dto/models/store_dto.dart';
import '../config/dto/parser/checker_config_dto_parser.dart';
import '../config/entity/checker_config.dart';
import '../config/entity/checker_config_parser.dart';
import '../config/entity/release.dart';
import '../config/entity/stores/fetchers/store_fetcher.dart';
import '../config/entity/version.dart';
import 'update_config_provider.dart';
import 'update_contoller_base.dart';
import 'update_data.dart';

class UpdateController extends UpdateContollerBase {
  final _parser = const CheckerConfigDTOParser();

  final _linker = const CheckerConfigParser();

  final _asyncPackageInfo = PackageInfo.fromPlatform();

  Completer<CheckerConfig>? _configDataCompleter;

  final UpdateConfigProvider? _updateConfigProvider;
  final StoreFetcherCoordinator? _storeFetcherCoordinator;
  final ReleaseSettingsDTO? _releaseSettings;
  final List<StoreDTO>? _stores;

  @override
  Stream<UpdateData> get availableUpdateStream => throw UnimplementedError();

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
  Future<UpdateData> findUpdate() {
    throw UnimplementedError();
  }

  @override
  Future<UpdateData?> findAvailableUpdate() async {
    final latestRelease = await _findLatestRelease();

    if (latestRelease == null) return null;

    // ignore: avoid-non-null-assertion
    final configData = await _configDataCompleter!.future;
    final packageInfo = await _asyncPackageInfo;

    final appName = packageInfo.appName;
    final appVersion = Version.parse(packageInfo.version);

    final deprecatedBeforeVersion =
        configData.releaseSettings.deprecatedBeforeVersion;
    // ignore: prefer-boolean-prefixes
    final appVersonIsDeprecated =
        deprecatedBeforeVersion != null && appVersion < deprecatedBeforeVersion;

    final updateData = UpdateData(
      appName: appName,
      appVersion: appVersion,
      appVersonIsDeprecated: appVersonIsDeprecated,
      config: configData,
      release: latestRelease,
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

  Future<Release?> _findLatestRelease() async {
    // ignore: unused_local_variable, avoid-non-null-assertion
    final configData = await _configDataCompleter!.future;
    // ignore: unused_local_variable
    final packageInfo = await _asyncPackageInfo;

    // TODO: implement it
    return configData.releases.lastOrNull;
  }
}
