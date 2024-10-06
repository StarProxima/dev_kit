import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

import '../linker/models/release_data.dart';
import '../shared/update_status_wrapper.dart';
import 'models/release.dart';
import 'models/release_settings.dart';
import 'models/update_texts.dart';

class UpdateLocalizer {
  final PackageInfo packageInfo;

  String get appName => packageInfo.appName;
  Version get appVersion => Version.parse(packageInfo.version);

  const UpdateLocalizer({
    required this.packageInfo,
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

    // TODO: С учётом того, что UpdateLocalizer мержит настройки с настройками по умолчанию, он не Localizer
    final defaultSettings = UpdateSettings.base();

    final localizedSettings = releaseData.settings.value.map(
      (alertType, value) => MapEntry(
        alertType,
        value.map(
          (status, releaseSettingsData) {
            final settings = ReleaseSettings.fromData(
              data: releaseSettingsData,
              defaultSettings: defaultSettings.getByRaw(
                type: alertType,
                status: status,
              ),
            );

            final loxalizedText = interpolationUpdateTranslation(settings.texts);
            final localizedSettings = settings.copyWith(
              texts: loxalizedText,
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
