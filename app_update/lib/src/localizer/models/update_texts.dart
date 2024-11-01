import 'dart:ui';

import '../../parser/models/settings_translations.dart';
import '../../shared/text_translations.dart';

class UpdateTranslations {
  final Map<Locale, UpdateTexts> value;

  const UpdateTranslations(this.value);

  factory UpdateTranslations.fromData({
    required UpdateTranslationsData? rawTranslations,
    required UpdateTranslations defaultTexts,
  }) {
    final trList = [
      rawTranslations?.title,
      rawTranslations?.description,
      rawTranslations?.releaseNotesTitle,
      rawTranslations?.releaseNotes,
      rawTranslations?.skipButtonText,
      rawTranslations?.laterButtonText,
      rawTranslations?.updateButtonText,
    ];

    final locales = {
      ...trList.expand((e) => e?.value.keys ?? <Locale>[]),
    };

    final value = <Locale, UpdateTexts>{};

    for (final locale in locales) {
      final localizedDefaultTexts = defaultTexts.byLocale(locale);

      final updateText = UpdateTexts(
        title: rawTranslations?.title?.byLocale(locale) ?? localizedDefaultTexts.title,
        description: rawTranslations?.description?.byLocale(locale) ?? localizedDefaultTexts.description,
        releaseNotesTitle:
            rawTranslations?.releaseNotesTitle?.byLocale(locale) ?? localizedDefaultTexts.releaseNotesTitle,
        releaseNotes: rawTranslations?.releaseNotes?.byLocale(locale) ?? localizedDefaultTexts.releaseNotes,
        skipButtonText: rawTranslations?.skipButtonText?.byLocale(locale) ?? localizedDefaultTexts.skipButtonText,
        laterButtonText: rawTranslations?.laterButtonText?.byLocale(locale) ?? localizedDefaultTexts.laterButtonText,
        updateButtonText: rawTranslations?.updateButtonText?.byLocale(locale) ?? localizedDefaultTexts.updateButtonText,
      );

      value[locale] = updateText;
    }

    return UpdateTranslations(value);
  }

  UpdateTexts byLocale(Locale locale) =>
      value[locale] ??
      value[kAppUpdateDefaultLocale] ??
      value.values.firstOrNull ??
      (throw Exception('At least one locale must be specified'));
}

class UpdateTexts {
  final String title;
  final String description;
  final String releaseNotesTitle;
  final String releaseNotes;
  final String skipButtonText;
  final String laterButtonText;
  final String updateButtonText;

  const UpdateTexts({
    required this.title,
    required this.description,
    required this.releaseNotesTitle,
    required this.releaseNotes,
    required this.skipButtonText,
    required this.laterButtonText,
    required this.updateButtonText,
  });
}
