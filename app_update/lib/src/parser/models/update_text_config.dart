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
    this.title,
    this.description,
    this.releaseNotesTitle,
    this.releaseNotes,
    this.skipButton,
    this.laterButton,
    this.updateButton,
    this.customData,
  });

  const UpdateTextConfig.byRequired({
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
