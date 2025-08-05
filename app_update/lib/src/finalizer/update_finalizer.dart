// ignore_for_file: avoid-long-functions

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

  final UpdateTextDataContainer? textContainer;
  final UpdateSettingsDataContainer? settingsContainer;

  static final _defaultTextContainer = DefaultUpdateTextDataContainer();
  static const _defaultSettingsContainer = DefaultUpdateSettingsDataContainer();

  const UpdateFinalizer({
    required this.appName,
    required this.appVersion,
    required this.textContainer,
    required this.settingsContainer,
  });

  List<Release> finalizeReleases(List<ReleaseData> releases) {
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

    UpdateContent interpolateUpdateText(UpdateContent text) => UpdateContent(
          title: interpolate(text.title),
          description: interpolate(text.description),
          releaseNotesTitle: interpolate(text.releaseNotesTitle),
          releaseNotes: interpolate(text.releaseNotes),
          skipButton: interpolate(text.skipButton),
          laterButton: interpolate(text.laterButton),
          updateButton: interpolate(text.updateButton),
          customData: text.customData,
        );

    final text = UpdateTextContainer(
      defaultContainer: _defaultTextContainer,
      controllerContainer: textContainer,
      containerStorage: releaseData.textContainers,
      interpolate: interpolateUpdateText,
    );

    final settings = UpdateSettingsContainer(
      defaultContainer: _defaultSettingsContainer,
      controllerContainer: settingsContainer,
      containerStorage: releaseData.settingsContainers,
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
