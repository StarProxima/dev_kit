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

  UpdateTextConfig merge(UpdateTextConfig? data) {
    final customData = {...?this.customData, ...?data?.customData};

    return UpdateTextConfig.byRequired(
      title: data?.title ?? title,
      description: data?.description ?? description,
      releaseNotesTitle: data?.releaseNotesTitle ?? releaseNotesTitle,
      releaseNotes: data?.releaseNotes ?? releaseNotes,
      skipButton: data?.skipButton ?? skipButton,
      laterButton: data?.laterButton ?? laterButton,
      updateButton: data?.updateButton ?? updateButton,
      customData: customData.isEmpty ? null : customData,
    );
  }
}
