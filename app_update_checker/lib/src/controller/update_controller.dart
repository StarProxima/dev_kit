import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/dto/parser/checker_config_dto_parser.dart';
import '../config/entity/checker_config.dart';
import '../config/entity/checker_config_parser.dart';
import '../config/entity/release.dart';
import '../config/entity/version.dart';
import 'update_contoller_base.dart';
import 'update_data.dart';

class UpdateController extends UpdateContollerBase {
  final _parser = const CheckerConfigDTOParser();

  final _linker = const CheckerConfigParser();

  final _asyncPackageInfo = PackageInfo.fromPlatform();

  Completer<CheckerConfig>? _configDataCompleter;

  @override
  Stream<UpdateData> get updateStream => throw UnimplementedError();

  UpdateController({
    required super.updateConfigProvider,
    super.autoFetch,
    super.storeFetcherCoordinator,
    super.releaseSettings,
    super.stores,
    super.onUpdate,
  });

  @override
  Future<void> fetch() async {
    _configDataCompleter = Completer();

    final provider = updateConfigProvider;
    if (provider == null) return;

    final rawConfig = await provider.fetch();

    final config = _parser.parseConfig(rawConfig, isDebug: kDebugMode);

    final configData = _linker.parseFromDTO(config);

    // TODO: Process with localizaton and interpolation

    _configDataCompleter?.complete(configData);

    final updateData = await _buildUpdateData();

    if (updateData == null) return;

    onUpdate?.call(updateData);

    throw UnimplementedError();
  }

  Future<Release?> findLatestRelease() async {
    // ignore: unused_local_variable, avoid-non-null-assertion
    final configData = await _configDataCompleter!.future;
    // ignore: unused_local_variable
    final packageInfo = await _asyncPackageInfo;

    // TODO: implement it
    return configData.releases.lastOrNull;
  }

  Future<UpdateData?> _buildUpdateData() async {
    final latestRelease = await findLatestRelease();

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
}
