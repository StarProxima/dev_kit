import '../../default_settings/translations/default_update_translations.dart';
import '../../parser/models/update_text_config.dart';

/// See aloso [DefaultUpdateTexts].
class UpdateText {
  final String title;
  final String description;
  final String releaseNotesTitle;
  final String releaseNotes;
  final String skipButton;
  final String laterButton;
  final String updateButton;

  const UpdateText({
    required this.title,
    required this.description,
    required this.releaseNotesTitle,
    required this.releaseNotes,
    required this.skipButton,
    required this.laterButton,
    required this.updateButton,
  });

  factory UpdateText.fromConfig(
    UpdateTextConfig? config, {
    required UpdateText defaultText,
  }) {
    return UpdateText(
      title: config?.title ?? defaultText.title,
      description: config?.description ?? defaultText.description,
      releaseNotesTitle: config?.releaseNotesTitle ?? defaultText.releaseNotesTitle,
      releaseNotes: config?.releaseNotes ?? defaultText.releaseNotes,
      skipButton: config?.skipButton ?? defaultText.skipButton,
      laterButton: config?.laterButton ?? defaultText.laterButton,
      updateButton: config?.updateButton ?? defaultText.updateButton,
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
  }) =>
      UpdateText(
        title: title ?? this.title,
        description: description ?? this.description,
        releaseNotesTitle: releaseNotesTitle ?? this.releaseNotesTitle,
        releaseNotes: releaseNotes ?? this.releaseNotes,
        skipButton: skipButton ?? this.skipButton,
        laterButton: laterButton ?? this.laterButton,
        updateButton: updateButton ?? this.updateButton,
      );
}
