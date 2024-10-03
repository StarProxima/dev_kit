// ignore_for_file: avoid-unnecessary-reassignment, avoid-nested-switches, prefer-correct-identifier-length

import 'dart:ui';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../shared/text_translations.dart';
import '../shared/update_status_wrapper.dart';
import '../version_controller/models/release_data_with_status.dart';
import 'models/release.dart';
import 'models/release_settings.dart';
import 'models/update_texts.dart';

class UpdateLocalizer {
  final Locale appLocale;
  final PackageInfo packageInfo;

  String get appName => packageInfo.appName;
  Version get appVersion => Version.parse(packageInfo.version);

  const UpdateLocalizer({
    required this.appLocale,
    required this.packageInfo,
  });

  List<Release> localizeReleasesData(List<ReleaseDataWithStatus> releases) {
    return releases.map(localizeRelease).toList();
  }

  Release localizeRelease(ReleaseDataWithStatus releaseDataWithStatus) {
    final (releaseData, status) = releaseDataWithStatus;

    String? interpolation(String? text) => text
        ?.replaceAll(r'$appName', appName)
        .replaceAll(
          r'$appVersion',
          appVersion.toString(),
        )
        .replaceAll(
          r'$releaseVersion',
          releaseData.version.toString(),
        );

    final settingsData = releaseData.settings;
    // TODO: Задавать дефолтный UpdateSettings для разных типов и статусов,
    // а не обрабатывать отдельным кейсом
    // (В отдельном файлике просто создать дефолтный которой можно использовать)
    if (settingsData == null) {
      return Release(
        version: releaseData.version,
        targetSource: releaseData.targetSource,
        status: status,
        dateUtc: releaseData.dateUtc,
        settings: UpdateSettings.empty(),
        customData: releaseData.customData,
      );
    }

    final localizedSettings = settingsData.value.map(
      (key, value) => MapEntry(
        key,
        value.map(
          (key, releaseSettingsData) {
            final translations = releaseSettingsData.translations;
            final title = interpolation(translations?.title?.byLocale(appLocale));
            final description = interpolation(translations?.description?.byLocale(appLocale));
            final laterButtonText = interpolation(translations?.laterButtonText?.byLocale(appLocale));
            final skipButtonText = interpolation(translations?.skipButtonText?.byLocale(appLocale));
            final updateButtonText = interpolation(translations?.updateButtonText?.byLocale(appLocale));
            final releaseNoteTitle = interpolation(translations?.releaseNoteTitle?.byLocale(appLocale));
            final releaseNote = interpolation(translations?.releaseNote?.byLocale(appLocale));

            return MapEntry(
              key,
              ReleaseSettings.fromData(
                data: releaseSettingsData,
                texts: UpdateTexts(
                  title: title,
                  description: description,
                  releaseNoteTitle: releaseNoteTitle,
                  releaseNote: releaseNote,
                  skipButtonText: skipButtonText,
                  laterButtonText: laterButtonText,
                  updateButtonText: updateButtonText,
                ),
              ),
            );
          },
        ),
      ),
    );

    return Release(
      version: releaseData.version,
      targetSource: releaseData.targetSource,
      status: status,
      dateUtc: releaseData.dateUtc,
      settings: UpdateSettings(localizedSettings),
      customData: releaseData.customData,
    );
  }
}
