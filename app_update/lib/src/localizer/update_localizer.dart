import 'package:pub_semver/pub_semver.dart';

import '../linker/models/release_data.dart';
import '../shared/update_status_wrapper.dart';
import 'models/release.dart';
import 'models/release_settings.dart';
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

    UpdateTranslations interpolationUpdateTranslation(UpdateTranslations text) => UpdateTranslations(
          text.value.map(
            (locale, texts) => MapEntry(
              locale,
              UpdateTexts(
                title: interpolation(texts.title),
                description: interpolation(texts.description),
                releaseNoteTitle: interpolation(texts.releaseNoteTitle),
                releaseNote: interpolation(texts.releaseNote),
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
          (status, releaseSettingsData) {
            final settings = ReleaseSettings.fromData(data: releaseSettingsData);

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
      dateUtc: releaseData.dateUtc,
      settings: UpdateSettings(localizedSettings),
      customData: releaseData.customData,
    );
  }
}
