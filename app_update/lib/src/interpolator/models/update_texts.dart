import 'dart:ui';

import '../../parser/models/settings_translations.dart';
import '../../default_settings/translations/default_update_translations.dart';
import '../../shared/text_translations.dart';

/// See aloso [DefaultUpdateTexts].
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

  UpdateTexts copyWith({
    String? title,
    String? description,
    String? releaseNotesTitle,
    String? releaseNotes,
    String? skipButtonText,
    String? laterButtonText,
    String? updateButtonText,
  }) =>
      UpdateTexts(
        title: title ?? this.title,
        description: description ?? this.description,
        releaseNotesTitle: releaseNotesTitle ?? this.releaseNotesTitle,
        releaseNotes: releaseNotes ?? this.releaseNotes,
        skipButtonText: skipButtonText ?? this.skipButtonText,
        laterButtonText: laterButtonText ?? this.laterButtonText,
        updateButtonText: updateButtonText ?? this.updateButtonText,
      );
}

/// See aloso [DefaultUpdateTranslations].
class UpdateTranslations {
  final Map<Locale, UpdateTexts> value;

  const UpdateTranslations(this.value);

  factory UpdateTranslations.base() = DefaultUpdateTranslations.base;

  factory UpdateTranslations.merge(
    Map<Locale, UpdateTexts> translations,
  ) = DefaultUpdateTranslations.merge;

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
