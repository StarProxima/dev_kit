// ignore_for_file: avoid-unnecessary-reassignment

import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../linker/models/release_data.dart';
import '../linker/models/update_config_data.dart';
import '../models/version.dart';
import 'models/app_update.dart';
import 'models/release.dart';
import 'models/update_config.dart';

class UpdateBuilder {
  final Locale applocale;
  final PackageInfo packageInfo;

  const UpdateBuilder({
    required this.applocale,
    required this.packageInfo,
  });

  AppUpdate? findUpdate(UpdateConfigData configData) {
    final appName = packageInfo.appName;
    final appVersion = Version.parse(packageInfo.version);

    final config = _localizeConfig(configData);
    final availableRelease = _findAvailableRelease(
      config: config,
      appVersion: appVersion,
    );

    if (availableRelease == null) return null;

    return AppUpdate(
      appName: appName,
      appVersion: appVersion,
      appLocale: applocale,
      config: config,
      availableRelease: availableRelease,
    );
  }

  Release _localizeRelease(ReleaseData releaseData) {
    return Release.localizedFromReleaseData(
      releaseData: releaseData,
      locale: applocale,
      appName: packageInfo.appName,
      appVersion: Version.parse(packageInfo.version),
    );
  }

  UpdateConfig _localizeConfig(UpdateConfigData updateConfig) {
    return UpdateConfig(
      releaseSettings: updateConfig.releaseSettings,
      stores: updateConfig.stores,
      releases: updateConfig.releases.map(_localizeRelease).toList(),
      customData: updateConfig.customData,
    );
  }

  // ignore: avoid-unnecessary-nullable-return-type
  Release? _findAvailableRelease({
    required UpdateConfig config,
    required Version appVersion,
  }) {
    // ignore: avoid-unsafe-collection-methods
    return config.releases.first;
  }
}
