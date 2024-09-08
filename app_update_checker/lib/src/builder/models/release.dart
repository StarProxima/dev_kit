import 'dart:ui';

import '../../data/localized_text.dart';
import '../../linker/models/release_data.dart';
import '../../models/version.dart';

class Release extends ReleaseData {
  final String title;
  final String description;
  final String? releaseNote;

  const Release({
    required super.version,
    required super.refVersion,
    required super.buildNumber,
    required super.status,
    required this.title,
    required super.titleTranslations,
    required this.description,
    required super.descriptionTranslations,
    required this.releaseNote,
    required super.releaseNoteTranslations,
    required super.publishDateUtc,
    required super.canIgnoreRelease,
    required super.reminderPeriod,
    required super.releaseDelay,
    required super.stores,
    required super.customData,
  });

  factory Release.localizedFromReleaseData({
    required ReleaseData releaseData,
    required Locale locale,
    required String appName,
    required Version appVersion,
  }) {
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

    final title = interpolation(releaseData.titleTranslations.byLocale(locale));

    final description = interpolation(releaseData.descriptionTranslations.byLocale(locale));

    final releaseNoteTranslations = releaseData.releaseNoteTranslations;
    final releaseNote =
        releaseNoteTranslations == null ? null : interpolation(releaseNoteTranslations.byLocale(locale));

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
