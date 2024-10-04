// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment
part of '../update_config_parser.dart';

class SettingsTranslationsParser {
  TextTranslationsParser get _textParser => const TextTranslationsParser();

  const SettingsTranslationsParser();

  UpdateTranslations? parse(
    // ignore: avoid-dynamic
    dynamic value, {
    required bool isDebug,
  }) {
    if (value is! Map<String, dynamic>?) {
      throw const UpdateConfigException();
    }

    if (value == null) return null;

    // title
    final titleValue = value.remove('title');
    final title = _textParser.parse(
      titleValue,
      isDebug: isDebug,
    );

    // description
    final descriptionValue = value.remove('description');
    final description = _textParser.parse(
      descriptionValue,
      isDebug: isDebug,
    );

    // releaseNoteTitle
    final releaseNoteTitleValue = value.remove('releaseNoteTitle');
    final releaseNoteTitle = _textParser.parse(
      releaseNoteTitleValue,
      isDebug: isDebug,
    );

    // releaseNote
    final releaseNoteValue = value.remove('releaseNote');
    final releaseNote = _textParser.parse(
      releaseNoteValue,
      isDebug: isDebug,
    );

    // skipButtonText
    final skipButtonTextValue = value.remove('skipButtonText');
    final skipButtonText = _textParser.parse(
      skipButtonTextValue,
      isDebug: isDebug,
    );

    // laterButtonText
    final laterButtonTextValue = value.remove('laterButtonText');
    final laterButtonText = _textParser.parse(
      laterButtonTextValue,
      isDebug: isDebug,
    );

    // updateButtonText
    final updateButtonTextValue = value.remove('updateButtonText');
    final updateButtonText = _textParser.parse(
      updateButtonTextValue,
      isDebug: isDebug,
    );

    return UpdateTranslations(
      title: title,
      description: description,
      releaseNoteTitle: releaseNoteTitle,
      releaseNote: releaseNote,
      skipButtonText: skipButtonText,
      laterButtonText: laterButtonText,
      updateButtonText: updateButtonText,
    );
  }
}
