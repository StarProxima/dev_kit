// ignore_for_file: avoid-collection-mutating-methods, prefer-type-over-var, avoid-unnecessary-reassignment

import '../../primitive_parsers/string_parser.dart';
import '../../update_config_exception.dart';
import 'update_app_status_config.dart';

class UpdateAppStatusConfigParser {
  StringParser get _stringParser => const StringParser();

  const UpdateAppStatusConfigParser();

  UpdateAppStatusConfig? parse(
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
    final title = _stringParser.parse(
      titleValue,
      isDebug: isDebug,
    );

    // description
    final descriptionValue = value.remove('description');
    final description = _stringParser.parse(
      descriptionValue,
      isDebug: isDebug,
    );

    // releaseNotesTitle
    final releaseNotesTitleValue = value.remove('release_note_title');
    final releaseNotesTitle = _stringParser.parse(
      releaseNotesTitleValue,
      isDebug: isDebug,
    );

    // releaseNotes
    final releaseNotesValue = value.remove('release_notes');
    final releaseNotes = _stringParser.parse(
      releaseNotesValue,
      isDebug: isDebug,
    );

    // skipButton
    final skipButtonValue = value.remove('skip_button');
    final skipButton = _stringParser.parse(
      skipButtonValue,
      isDebug: isDebug,
    );

    // laterButton
    final laterButtonValue = value.remove('later_button');
    final laterButton = _stringParser.parse(
      laterButtonValue,
      isDebug: isDebug,
    );

    // updateButton
    final updateButtonValue = value.remove('update_button');
    final updateButton = _stringParser.parse(
      updateButtonValue,
      isDebug: isDebug,
    );

    return UpdateContentConfig.byRequired(
      title: title,
      description: description,
      releaseNotesTitle: releaseNotesTitle,
      releaseNotes: releaseNotes,
      skipButton: skipButton,
      postponeButton: laterButton,
      updateButton: updateButton,
      customData: value,
    );
  }
}
