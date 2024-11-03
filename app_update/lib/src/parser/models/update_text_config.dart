class UpdateTextConfig {
  final String? title;
  final String? description;
  final String? releaseNotesTitle;
  final String? releaseNotes;
  final String? skipButton;
  final String? laterButton;
  final String? updateButton;
  final Map<String, dynamic>? customData;

  const UpdateTextConfig({
    required this.title,
    required this.description,
    required this.releaseNotesTitle,
    required this.releaseNotes,
    required this.skipButton,
    required this.laterButton,
    required this.updateButton,
    required this.customData,
  });
}
