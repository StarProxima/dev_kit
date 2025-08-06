class UpdateContentConfig {
  final String? title;
  final String? description;
  final String? releaseNotesTitle;
  final String? releaseNotes;
  final String? skipButton;
  final String? postponeButton;
  final String? updateButton;
  final Map<String, dynamic>? customData;

  const UpdateContentConfig({
    this.title,
    this.description,
    this.releaseNotesTitle,
    this.releaseNotes,
    this.skipButton,
    this.postponeButton,
    this.updateButton,
    this.customData,
  });

  const UpdateContentConfig.byRequired({
    required this.title,
    required this.description,
    required this.releaseNotesTitle,
    required this.releaseNotes,
    required this.skipButton,
    required this.postponeButton,
    required this.updateButton,
    required this.customData,
  });
}
