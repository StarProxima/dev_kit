import '../../shared/text_translations.dart';

class UpdateTranslations {
  final TextTranslations? title;
  final TextTranslations? description;
  final TextTranslations? releaseNoteTitle;
  final TextTranslations? releaseNote;
  final TextTranslations? skipButtonText;
  final TextTranslations? laterButtonText;
  final TextTranslations? updateButtonText;

  const UpdateTranslations({
    required this.title,
    required this.description,
    required this.releaseNoteTitle,
    required this.releaseNote,
    required this.skipButtonText,
    required this.laterButtonText,
    required this.updateButtonText,
  });
}
