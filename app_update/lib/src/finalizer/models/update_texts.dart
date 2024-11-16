import '../../linker/models/update_text_data.dart';

class UpdateText {
  final String title;
  final String description;
  final String releaseNotesTitle;
  final String releaseNotes;
  final String skipButton;
  final String laterButton;
  final String updateButton;

  final Map<String, dynamic>? customData;

  const UpdateText({
    required this.title,
    required this.description,
    required this.releaseNotesTitle,
    required this.releaseNotes,
    required this.skipButton,
    required this.laterButton,
    required this.updateButton,
    required this.customData,
  });

  factory UpdateText.fromData(
    UpdateTextData? data, {
    required UpdateText defaultText,
  }) {
    return UpdateText(
      title: data?.title ?? defaultText.title,
      description: data?.description ?? defaultText.description,
      releaseNotesTitle: data?.releaseNotesTitle ?? defaultText.releaseNotesTitle,
      releaseNotes: data?.releaseNotes ?? defaultText.releaseNotes,
      skipButton: data?.skipButton ?? defaultText.skipButton,
      laterButton: data?.laterButton ?? defaultText.laterButton,
      updateButton: data?.updateButton ?? defaultText.updateButton,
      customData: data?.customData,
    );
  }

  UpdateText merge(UpdateTextData? data) {
    return UpdateText(
      title: data?.title ?? title,
      description: data?.description ?? description,
      releaseNotesTitle: data?.releaseNotesTitle ?? releaseNotesTitle,
      releaseNotes: data?.releaseNotes ?? releaseNotes,
      skipButton: data?.skipButton ?? skipButton,
      laterButton: data?.laterButton ?? laterButton,
      updateButton: data?.updateButton ?? updateButton,
      customData: data?.customData ?? customData,
    );
  }

  UpdateText copyWith({
    String? title,
    String? description,
    String? releaseNotesTitle,
    String? releaseNotes,
    String? skipButton,
    String? laterButton,
    String? updateButton,
    Map<String, dynamic>? customData,
  }) =>
      UpdateText(
        title: title ?? this.title,
        description: description ?? this.description,
        releaseNotesTitle: releaseNotesTitle ?? this.releaseNotesTitle,
        releaseNotes: releaseNotes ?? this.releaseNotes,
        skipButton: skipButton ?? this.skipButton,
        laterButton: laterButton ?? this.laterButton,
        updateButton: updateButton ?? this.updateButton,
        customData: customData ?? this.customData,
      );
}
