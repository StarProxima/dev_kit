// ignore_for_file: avoid-similar-names

import 'package:pub_semver/pub_semver.dart';

import '../default_settings/translations/default_update_translations.dart';
import '../linker/models/release_data.dart';
import '../shared/update_settings_container.dart';
import '../shared/update_text_container.dart';
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
          _regExpForField('appName'),
          appName,
        )
        .replaceAll(
          _regExpForField('appVersion'),
          appVersion.toString(),
        )
        .replaceAll(
          _regExpForField('releaseVersion'),
          releaseData.version.toString(),
        )
        .replaceAll(
          _regExpForField('source'),
          releaseData.source.title,
        );

    UpdateText interpolateUpdateText(UpdateText text) => UpdateText(
          title: interpolate(text.title),
          description: interpolate(text.description),
          releaseNotesTitle: interpolate(text.releaseNotesTitle),
          releaseNotes: interpolate(text.releaseNotes),
          skipButton: interpolate(text.skipButton),
          laterButton: interpolate(text.laterButton),
          updateButton: interpolate(text.updateButton),
        );

    final interpolatedTextMap = releaseData.text.value.map(
      (locale, value) => MapEntry(
        locale,
        value.map(
          (alertType, value) => MapEntry(
            alertType,
            value.map(
              (status, textConfig) {
                final updateText = UpdateText.fromConfig(
                  textConfig,
                  // TODO: Откуда доставать дефолтные
                  defaultText: const DefaultUpdateTexts.ru(),
                );

                final interpolatedText = interpolateUpdateText(updateText);

                return MapEntry(
                  status,
                  interpolatedText,
                );
              },
            ),
          ),
        ),
      ),
    );

    final settingsMap = releaseData.settings.value.map(
      (alertType, value) => MapEntry(
        alertType,
        value.map(
          (status, settings) {
            final updateSettings = UpdateSettings.fromData(
              settings,
              // TODO: Откуда доставать дефолтные
              defaultSettings: const UpdateSettings.base(),
            );

            return MapEntry(
              status,
              updateSettings,
            );
          },
        ),
      ),
    );

    final text = UpdateTextContainer(interpolatedTextMap);
    final settings = UpdateSettingsContainer(settingsMap);

    return Release(
      version: releaseData.version,
      source: releaseData.source,
      date: releaseData.date,
      text: text,
      settings: settings,
      customData: releaseData.customData,
    );
  }

  RegExp _regExpForField(String name) => RegExp('\$$name|{$name}|\${$name}');
}
