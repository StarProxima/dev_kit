import 'package:pub_semver/pub_semver.dart';

import '../linker/models/release_data.dart';
import '../shared/update_status_wrapper.dart';
import 'models/release.dart';
import 'models/update_settings.dart';
import 'models/update_texts.dart';

class UpdateLocalizer {
  final String appName;
  final Version appVersion;

  const UpdateLocalizer({
    required this.appName,
    required this.appVersion,
  });

  List<Release> localizeReleasesData(List<ReleaseData> releases) {
    return releases.map(localizeRelease).toList();
  }

  Release localizeRelease(ReleaseData releaseData) {
    // TODO: Оптимизировать, проходясь одной регуркой?
    String interpolation(String text) => text
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
          releaseData.targetSource.title,
        );

    UpdateTranslations interpolationUpdateTranslation(UpdateTranslations text) => UpdateTranslations(
          text.value.map(
            (locale, texts) => MapEntry(
              locale,
              UpdateTexts(
                title: interpolation(texts.title),
                description: interpolation(texts.description),
                releaseNotesTitle: interpolation(texts.releaseNotesTitle),
                releaseNotes: interpolation(texts.releaseNotes),
                skipButtonText: interpolation(texts.skipButtonText),
                laterButtonText: interpolation(texts.laterButtonText),
                updateButtonText: interpolation(texts.updateButtonText),
              ),
            ),
          ),
        );

    final localizedSettings = releaseData.settings.value.map(
      (alertType, value) => MapEntry(
        alertType,
        value.map(
          (status, updateSettingsData) {
            final settings = UpdateSettings.fromData(data: updateSettingsData);

            final localizedText = interpolationUpdateTranslation(settings.texts);

            final localizedSettings = settings.copyWith(
              texts: localizedText,
            );

            return MapEntry(
              status,
              localizedSettings,
            );
          },
        ),
      ),
    );

    return Release(
      version: releaseData.version,
      targetSource: releaseData.targetSource,
      date: releaseData.date,
      settings: UpdateSettingsContainer(localizedSettings),
      customData: releaseData.customData,
    );
  }
}
