// ignore_for_file: avoid-similar-names

import 'package:pub_semver/pub_semver.dart';

import '../linker/models/release_data.dart';
import '../shared/update_status_wrapper.dart';
import 'models/release.dart';
import 'models/update_settings.dart';
import 'models/update_texts.dart';

class UpdateInterpolator {
  final String appName;
  final Version appVersion;

  const UpdateInterpolator({
    required this.appName,
    required this.appVersion,
  });

  List<Release> interpolateReleases(List<ReleaseData> releases) {
    return releases.map(interpolateRelease).toList();
  }

  Release interpolateRelease(ReleaseData releaseData) {
    // TODO: Оптимизировать, проходясь одной регуркой?
    String interpolate(String text) => text
        .replaceAll(
          r'$appName',
          appName,
        )
        .replaceAll(
          r'$appVersion',
          appVersion.toString(),
        )
        .replaceAll(
          r'$releaseVersion',
          releaseData.version.toString(),
        )
        .replaceAll(
          r'$source',
          releaseData.source.title,
        );

    UpdateTranslations interpolateUpdateTranslation(UpdateTranslations text) => UpdateTranslations(
          text.value.map(
            (locale, texts) => MapEntry(
              locale,
              UpdateTexts(
                title: interpolate(texts.title),
                description: interpolate(texts.description),
                releaseNotesTitle: interpolate(texts.releaseNotesTitle),
                releaseNotes: interpolate(texts.releaseNotes),
                skipButtonText: interpolate(texts.skipButtonText),
                laterButtonText: interpolate(texts.laterButtonText),
                updateButtonText: interpolate(texts.updateButtonText),
              ),
            ),
          ),
        );

    final interpolatedSettingsMap = releaseData.settings.value.map(
      (alertType, value) => MapEntry(
        alertType,
        value.map(
          (status, updateSettingsData) {
            final settings = UpdateSettings.fromData(data: updateSettingsData);

            final interpolatedTranslations = interpolateUpdateTranslation(settings.translations);

            final interpolatedSettings = settings.copyWith(
              translations: interpolatedTranslations,
            );

            return MapEntry(
              status,
              interpolatedSettings,
            );
          },
        ),
      ),
    );

    return Release(
      version: releaseData.version,
      source: releaseData.source,
      date: releaseData.date,
      settings: UpdateSettingsContainer(interpolatedSettingsMap),
      customData: releaseData.customData,
    );
  }
}
