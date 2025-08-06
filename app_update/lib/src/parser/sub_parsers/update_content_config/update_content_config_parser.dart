// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../primitive_parsers/string_parser.dart';
import '../../update_config_exception.dart';
import 'update_content_config.dart';

class UpdateContentConfigParser {
  static const _stringParser = StringParser();

  const UpdateContentConfigParser();

  UpdateContentConfig? parse(
    dynamic value,
  ) {
    if (value is! Map<String, dynamic>?) {
      throw const UpdateConfigException();
    }

    if (value == null) return null;

    // title
    final titleValue = value.remove('title');
    final title = _stringParser.parse(titleValue);

    // description
    final descriptionValue = value.remove('description');
    final description = _stringParser.parse(descriptionValue);

    // releaseNotesTitle
    final releaseNotesTitleValue = value.remove('release_notes_title');
    final releaseNotesTitle = _stringParser.parse(releaseNotesTitleValue);

    // releaseNotes
    final releaseNotesValue = value.remove('release_notes');
    final releaseNotes = _stringParser.parse(releaseNotesValue);

    // skipButton
    final skipButtonValue = value.remove('skip_button');
    final skipButton = _stringParser.parse(skipButtonValue);

    // postponeButton
    final postponeButtonValue = value.remove('postpone_button');
    final postponeButton = _stringParser.parse(postponeButtonValue);

    // updateButton
    final updateButtonValue = value.remove('update_button');
    final updateButton = _stringParser.parse(updateButtonValue);

    return UpdateContentConfig.byRequired(
      title: title,
      description: description,
      releaseNotesTitle: releaseNotesTitle,
      releaseNotes: releaseNotes,
      skipButton: skipButton,
      postponeButton: postponeButton,
      updateButton: updateButton,
      customData: value,
    );
  }
}
