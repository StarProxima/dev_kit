// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment
part of '../update_config_parser.dart';

class SettingsTranslationsParser {
  TextTranslationsParser get _textParser => const TextTranslationsParser();

  const SettingsTranslationsParser();

  UpdateTranslationsData? parse(
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

    // releaseNotesTitle
    final releaseNotesTitleValue = value.remove('release_note_title');
    final releaseNotesTitle = _textParser.parse(
      releaseNotesTitleValue,
      isDebug: isDebug,
    );

    // releaseNotes
    final releaseNotesValue = value.remove('release_notes');
    final releaseNotes = _textParser.parse(
      releaseNotesValue,
      isDebug: isDebug,
    );

    // skipButtonText
    final skipButtonTextValue = value.remove('skip_button_text');
    final skipButtonText = _textParser.parse(
      skipButtonTextValue,
      isDebug: isDebug,
    );

    // laterButtonText
    final laterButtonTextValue = value.remove('later_button_text');
    final laterButtonText = _textParser.parse(
      laterButtonTextValue,
      isDebug: isDebug,
    );

    // updateButtonText
    final updateButtonTextValue = value.remove('update_button_text');
    final updateButtonText = _textParser.parse(
      updateButtonTextValue,
      isDebug: isDebug,
    );

    return UpdateTranslationsData(
      title: title,
      description: description,
      releaseNotesTitle: releaseNotesTitle,
      releaseNotes: releaseNotes,
      skipButtonText: skipButtonText,
      laterButtonText: laterButtonText,
      updateButtonText: updateButtonText,
    );
  }
}
