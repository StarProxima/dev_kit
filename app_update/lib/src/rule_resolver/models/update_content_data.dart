import '../../parser/sub_parsers/update_content_config/update_content_config.dart';
import 'mergeable.dart';

class UpdateContentData extends UpdateContentConfig with Mergeable {
  UpdateContentData({
    required super.title,
    required super.description,
    required super.releaseNotesTitle,
    required super.releaseNotes,
    required super.skipButton,
    required super.postponeButton,
    required super.updateButton,
    required super.customData,
  });

  @override
  UpdateContentData merge(covariant UpdateContentData other) {
    return UpdateContentData(
      title: other.title ?? title,
      description: other.description ?? description,
      releaseNotesTitle: other.releaseNotesTitle ?? releaseNotesTitle,
      releaseNotes: other.releaseNotes ?? releaseNotes,
      skipButton: other.skipButton ?? skipButton,
      postponeButton: other.postponeButton ?? postponeButton,
      updateButton: other.updateButton ?? updateButton,
      customData: mergeCustomData(customData, other.customData),
    );
  }
}
