class UpdateTexts {
  final String title;
  final String description;
  final String releaseNoteTitle;
  final String releaseNote;
  final String skipButtonText;
  final String laterButtonText;
  final String updateButtonText;

  const UpdateTexts({
    String? title,
    String? description,
    String? releaseNoteTitle,
    String? releaseNote,
    String? skipButtonText,
    String? laterButtonText,
    String? updateButtonText,
  })  : title = title ?? 'New update',
        description = description ?? 'New update',
        releaseNoteTitle = releaseNoteTitle ?? 'Changes:',
        releaseNote = releaseNote ?? 'Some fixes',
        skipButtonText = skipButtonText ?? 'Skip version',
        laterButtonText = laterButtonText ?? 'Update later',
        updateButtonText = updateButtonText ?? 'Update!';
}
