// ignore_for_file: avoid-similar-names, avoid-long-functions

import 'package:pub_semver/pub_semver.dart';

import '../default_settings/default_update_settings_container.dart';
import '../default_settings/translations/default_update_text_container.dart';
import '../linker/models/release_data.dart';
import '../linker/models/update_text_data.dart';
import '../shared/update_settings_container.dart';
import '../shared/update_text_container.dart';
import 'models/release.dart';
import 'models/update_settings.dart';
import 'models/update_texts.dart';

class UpdateFinalizer {
  final String appName;
  final Version appVersion;

  static final _defaulUpdateTextContainer = DefaultUpdateTextContainer();
  static final _defaultSettingsContainer = DefaultUpdateSettingsContainer();

  const UpdateFinalizer({
    required this.appName,
    required this.appVersion,
  });

  List<Release> fializeReleases(List<ReleaseData> releases) {
    return releases.map(finalizeRelease).toList();
  }

  Release finalizeRelease(ReleaseData releaseData) {
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

    final finalizedTextMap = releaseData.text.value.map(
      (locale, value) => MapEntry(
        locale,
        value.map(
          (alertType, value) => MapEntry(
            alertType,
            value.map(
              (status, textConfig) {
                final updateText = UpdateText.fromData(
                  UpdateTextData.fromConfig(textConfig),
                  defaultText: _defaulUpdateTextContainer.getByBase(
                    locale: locale,
                    type: alertType,
                    status: status,
                  ),
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

    final finalizedSettingsMap = releaseData.settings.value.map(
      (alertType, value) => MapEntry(
        alertType,
        value.map(
          (status, settings) {
            final defaultSettings = _defaultSettingsContainer.getByRaw(
              type: alertType,
              status: status,
            );

            final updateSettings = UpdateSettings.fromData(
              settings,
              defaultSettings: defaultSettings,
            );

            return MapEntry(
              status,
              updateSettings,
            );
          },
        ),
      ),
    );

    final text = UpdateTextContainer(finalizedTextMap);
    final settings = UpdateSettingsContainer(finalizedSettingsMap);

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
