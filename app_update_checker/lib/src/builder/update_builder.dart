// ignore_for_file: avoid-unnecessary-reassignment

import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../linker/models/release_data.dart' as data;
import '../models/version.dart';
import 'models/release.dart';

class UpdateBuilder {
  final Locale applocale;
  final PackageInfo packageInfo;

  const UpdateBuilder({
    required this.applocale,
    required this.packageInfo,
  });

  Release localizeRelease(data.ReleaseData releaseData) {
    return Release.localizedFromReleaseData(
      releaseData: releaseData,
      locale: applocale,
      appName: packageInfo.appName,
      appVersion: Version.parse(packageInfo.version),
    );
  }
}
