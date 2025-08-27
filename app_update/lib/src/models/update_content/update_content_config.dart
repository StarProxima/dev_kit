import '../../utils/mergeable.dart';

class UpdateContentConfig implements Mergeable<UpdateContentConfig> {
  final String? updateUrl;
  final String? title;
  final String? description;
  final String? releaseNotesTitle;
  final String? releaseNotes;
  final String? skipButton;
  final String? postponeButton;
  final String? updateButton;
  final Map<String, dynamic>? customData;

  const UpdateContentConfig({
    this.updateUrl,
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
    required this.updateUrl,
    required this.title,
    required this.description,
    required this.releaseNotesTitle,
    required this.releaseNotes,
    required this.skipButton,
    required this.postponeButton,
    required this.updateButton,
    required this.customData,
  });

  @override
  UpdateContentConfig merge(covariant UpdateContentConfig other) =>
      UpdateContentConfig.byRequired(
        updateUrl: other.updateUrl ?? updateUrl,
        title: other.title ?? title,
        description: other.description ?? description,
        releaseNotesTitle: other.releaseNotesTitle ?? releaseNotesTitle,
        releaseNotes: other.releaseNotes ?? releaseNotes,
        skipButton: other.skipButton ?? skipButton,
        postponeButton: other.postponeButton ?? postponeButton,
        updateButton: other.updateButton ?? updateButton,
        customData: Mergeable.mergeCustomData(customData, other.customData),
      );
}
