import '../../parser/models/update_text_config.dart';

class UpdateTextData extends UpdateTextConfig {
  const UpdateTextData({
    super.title,
    super.description,
    super.releaseNotesTitle,
    super.releaseNotes,
    super.skipButton,
    super.laterButton,
    super.updateButton,
    super.customData,
  });

  const UpdateTextData.byRequired({
    required super.title,
    required super.description,
    required super.releaseNotesTitle,
    required super.releaseNotes,
    required super.skipButton,
    required super.laterButton,
    required super.updateButton,
    required super.customData,
  });

  factory UpdateTextData.fromConfig(UpdateTextConfig? config) {
    return UpdateTextData.byRequired(
      title: config?.title,
      description: config?.description,
      releaseNotesTitle: config?.releaseNotesTitle,
      releaseNotes: config?.releaseNotes,
      skipButton: config?.skipButton,
      laterButton: config?.laterButton,
      updateButton: config?.updateButton,
      customData: config?.customData,
    );
  }

  UpdateTextData inherit(UpdateTextData? child) {
    final customData = {...?this.customData, ...?child?.customData};

    return UpdateTextData.byRequired(
      title: child?.title ?? title,
      description: child?.description ?? description,
      releaseNotesTitle: child?.releaseNotesTitle ?? releaseNotesTitle,
      releaseNotes: child?.releaseNotes ?? releaseNotes,
      skipButton: child?.skipButton ?? skipButton,
      laterButton: child?.laterButton ?? laterButton,
      updateButton: child?.updateButton ?? updateButton,
      customData: customData.isEmpty ? null : customData,
    );
  }
}
