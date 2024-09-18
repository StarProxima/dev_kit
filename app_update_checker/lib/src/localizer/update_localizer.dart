// ignore_for_file: avoid-unnecessary-reassignment, avoid-nested-switches, prefer-correct-identifier-length

import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../linker/models/release_data.dart';
import '../linker/models/update_config_data.dart';
import '../shared/text_translations.dart';
import 'models/release.dart';
import 'models/update_config.dart';

class UpdateLocalizer {
  final Locale appLocale;
  final PackageInfo packageInfo;

  String get appName => packageInfo.appName;
  Version get appVersion => Version.parse(packageInfo.version);

  const UpdateLocalizer({
    required this.appLocale,
    required this.packageInfo,
  });

  UpdateConfig localizeConfig(UpdateConfigData updateConfig) {
    return UpdateConfig(
      releaseSettings: updateConfig.releaseSettings,
      stores: updateConfig.stores,
      releases: updateConfig.releases.map(localizeRelease).toList(),
      customData: updateConfig.customData,
    );
  }

  Release localizeRelease(ReleaseData releaseData) {
    String interpolation(String text) => text
        .replaceAll(r'$appName', appName)
        .replaceAll(
          r'$appVersion',
          appVersion.toString(),
        )
        .replaceAll(
          r'$releaseVersion',
          releaseData.version.toString(),
        );

    final title = interpolation(releaseData.titleTranslations.byLocale(appLocale));

    final description = interpolation(releaseData.descriptionTranslations.byLocale(appLocale));

    final releaseNoteTranslations = releaseData.releaseNoteTranslations;
    final releaseNote =
        releaseNoteTranslations == null ? null : interpolation(releaseNoteTranslations.byLocale(appLocale));

    return Release(
      version: releaseData.version,
      refVersion: releaseData.refVersion,
      buildNumber: releaseData.buildNumber,
      status: releaseData.status,
      title: title,
      titleTranslations: releaseData.titleTranslations,
      description: description,
      descriptionTranslations: releaseData.descriptionTranslations,
      releaseNote: releaseNote,
      releaseNoteTranslations: releaseNoteTranslations,
      publishDateUtc: releaseData.publishDateUtc,
      canIgnoreRelease: releaseData.canIgnoreRelease,
      reminderPeriod: releaseData.reminderPeriod,
      releaseDelay: releaseData.releaseDelay,
      stores: releaseData.stores,
      customData: releaseData.customData,
    );
  }
}
