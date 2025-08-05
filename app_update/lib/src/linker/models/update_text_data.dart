import '../../parser/models/update_content_config.dart';

class UpdateTextData extends UpdateContentConfig {
  const UpdateTextData({
    super.title,
    super.description,
    super.releaseNotesTitle,
    super.releaseNotes,
    super.skipButton,
    super.postponeButton,
    super.updateButton,
    super.customData,
  });

  const UpdateTextData.byRequired({
    required super.title,
    required super.description,
    required super.releaseNotesTitle,
    required super.releaseNotes,
    required super.skipButton,
    required super.postponeButton,
    required super.updateButton,
    required super.customData,
  });

  factory UpdateTextData.fromConfig(UpdateContentConfig? config) {
    return UpdateTextData.byRequired(
      title: config?.title,
      description: config?.description,
      releaseNotesTitle: config?.releaseNotesTitle,
      releaseNotes: config?.releaseNotes,
      skipButton: config?.skipButton,
      postponeButton: config?.postponeButton,
      updateButton: config?.updateButton,
      customData: config?.customData,
    );
  }

  UpdateTextData merge(UpdateTextData? child) {
    final customData = {...?this.customData, ...?child?.customData};

    return UpdateTextData.byRequired(
      title: child?.title ?? title,
      description: child?.description ?? description,
      releaseNotesTitle: child?.releaseNotesTitle ?? releaseNotesTitle,
      releaseNotes: child?.releaseNotes ?? releaseNotes,
      skipButton: child?.skipButton ?? skipButton,
      postponeButton: child?.postponeButton ?? postponeButton,
      updateButton: child?.updateButton ?? updateButton,
      customData: customData.isEmpty ? null : customData,
    );
  }
}
