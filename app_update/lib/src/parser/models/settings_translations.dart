import '../../shared/text_translations.dart';

class UpdateTranslationsData {
  final TextTranslations? title;
  final TextTranslations? description;
  final TextTranslations? releaseNotesTitle;
  final TextTranslations? releaseNotes;
  final TextTranslations? skipButtonText;
  final TextTranslations? laterButtonText;
  final TextTranslations? updateButtonText;

  const UpdateTranslationsData({
    required this.title,
    required this.description,
    required this.releaseNotesTitle,
    required this.releaseNotes,
    required this.skipButtonText,
    required this.laterButtonText,
    required this.updateButtonText,
  });
}
