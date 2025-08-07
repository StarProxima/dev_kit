// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../primitive_parsers/string_parser.dart';
import '../../common.dart';
import 'update_content_config.dart';

class UpdateContentConfigParser {
  static const _stringParser = StringParser();

  const UpdateContentConfigParser();

  UpdateContentConfig? parse(
    dynamic value,
  ) {
    if (value == null) return null;

    if (value is! Map) {
      throw const UpdateConfigException();
    }

    final map = Map<String, dynamic>.from(value);

    // title
    final titleValue = map.remove('title');
    final title = _stringParser.parse(titleValue);

    // description
    final descriptionValue = map.remove('description');
    final description = _stringParser.parse(descriptionValue);

    // releaseNotesTitle
    final releaseNotesTitleValue = map.remove('release_notes_title');
    final releaseNotesTitle = _stringParser.parse(releaseNotesTitleValue);

    // releaseNotes
    final releaseNotesValue = map.remove('release_notes');
    final releaseNotes = _stringParser.parse(releaseNotesValue);

    // skipButton
    final skipButtonValue = map.remove('skip_button');
    final skipButton = _stringParser.parse(skipButtonValue);

    // postponeButton
    final postponeButtonValue = map.remove('postpone_button');
    final postponeButton = _stringParser.parse(postponeButtonValue);

    // updateButton
    final updateButtonValue = map.remove('update_button');
    final updateButton = _stringParser.parse(updateButtonValue);

    return UpdateContentConfig.byRequired(
      title: title,
      description: description,
      releaseNotesTitle: releaseNotesTitle,
      releaseNotes: releaseNotes,
      skipButton: skipButton,
      postponeButton: postponeButton,
      updateButton: updateButton,
      customData: map,
    );
  }
}
