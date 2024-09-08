// ignore_for_file: avoid-unnecessary-reassignment

import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';

import '../linker/models/release_data.dart' as data;
import '../models/localized_text.dart';
import '../models/version.dart';
import 'models/release.dart';

class UpdateBuilder {
  final Locale applocale;
  final PackageInfo packageInfo;

  const UpdateBuilder({
    required this.applocale,
    required this.packageInfo,
  });

  Release fromReleaseData(data.ReleaseData releaseData) {
    String interpolation(String text) => text
        .replaceAll(r'$appName', packageInfo.appName)
        .replaceAll(r'$appVersion', Version.parse(packageInfo.version).toString())
        .replaceAll(r'$releaseVersion', releaseData.version.toString());

    final title = interpolation(releaseData.title.byLocale(applocale));

    final description = interpolation(releaseData.description.byLocale(applocale));

    final releaseNoteMap = releaseData.releaseNote;
    final releaseNote = releaseNoteMap == null ? null : interpolation(releaseNoteMap.byLocale(applocale));

    return Release(
      version: releaseData.version,
      refVersion: releaseData.refVersion,
      buildNumber: releaseData.buildNumber,
      status: releaseData.status,
      title: title,
      description: description,
      releaseNote: releaseNote,
      publishDateUtc: releaseData.publishDateUtc,
      canIgnoreRelease: releaseData.canIgnoreRelease,
      reminderPeriod: releaseData.reminderPeriod,
      releaseDelay: releaseData.releaseDelay,
      stores: releaseData.stores,
      customData: releaseData.customData,
    );
  }
}
