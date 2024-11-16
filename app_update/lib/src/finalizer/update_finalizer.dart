// ignore_for_file: avoid-long-functions, avoid-late-keyword

import 'package:pub_semver/pub_semver.dart';

import '../default_settings/default_update_settings_container.dart';
import '../default_settings/translations/default_update_text_container.dart';
import '../linker/models/release_data.dart';
import '../linker/models/update_settings_data_container.dart';
import '../linker/models/update_text_data_container.dart';
import 'models/release.dart';
import 'models/update_settings_container.dart';
import 'models/update_text_container.dart';
import 'models/update_texts.dart';

class UpdateFinalizer {
  final String appName;
  final Version appVersion;

  late final UpdateTextDataContainer _textContainer;
  late final UpdateSettingsDataContainer _settingsContainer;

  UpdateFinalizer({
    required this.appName,
    required this.appVersion,
    required UpdateTextDataContainer? textContainer,
    required UpdateSettingsDataContainer? settingsContainer,
  }) {
    final defaultTextContainer = DefaultUpdateTextDataContainer();
    const defaultSettingsContainer = DefaultUpdateSettingsDataContainer();

    _textContainer = textContainer == null
        ? defaultTextContainer
        : defaultTextContainer.inherit(
            textContainer,
          );
    _settingsContainer = settingsContainer == null
        ? defaultSettingsContainer
        : defaultSettingsContainer.inherit(
            settingsContainer,
          );
  }

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
          customData: text.customData,
        );

    final textContainer = _textContainer.inherit(releaseData.text);
    final text = UpdateTextContainer(
      dataContainer: textContainer,
      interpolate: interpolateUpdateText,
    );

    final settingsContainer = _settingsContainer.inherit(releaseData.settings);
    final settings = UpdateSettingsContainer(
      dataContainer: settingsContainer,
    );

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
