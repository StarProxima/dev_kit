import 'update_content_config.dart';

class UpdateContentData {
  final String updateUrl;
  final String title;
  final String description;
  final String releaseNotesTitle;
  final String? releaseNotes;
  final String skipButton;
  final String postponeButton;
  final String updateButton;
  final Map<String, dynamic>? customParams;

  const UpdateContentData({
    required this.updateUrl,
    required this.title,
    required this.description,
    required this.releaseNotesTitle,
    required this.releaseNotes,
    required this.skipButton,
    required this.postponeButton,
    required this.updateButton,
    required this.customParams,
  });

  factory UpdateContentData.fromConfig(UpdateContentConfig config) {
    return UpdateContentData(
      updateUrl:
          config.updateUrl ?? (throw ArgumentError('updateUrl is required')),
      title: config.title ?? (throw ArgumentError('title is required')),
      description: config.description ??
          (throw ArgumentError('description is required')),
      releaseNotesTitle: config.releaseNotesTitle ??
          (throw ArgumentError('releaseNotesTitle is required')),
      releaseNotes: config.releaseNotes,
      skipButton:
          config.skipButton ?? (throw ArgumentError('skipButton is required')),
      postponeButton: config.postponeButton ??
          (throw ArgumentError('postponeButton is required')),
      updateButton: config.updateButton ??
          (throw ArgumentError('updateButton is required')),
      customParams: config.customParams,
    );
  }

  UpdateContentData interpolate(Map<String, String> interpolateData) {
    final interpolatedcustomParams = customParams?.map(
      (key, value) => MapEntry(
        key,
        value is String ? _interpolateString(value, interpolateData) : value,
      ),
    );

    final data = UpdateContentData(
      updateUrl: _interpolateString(updateUrl, interpolateData),
      title: _interpolateString(title, interpolateData),
      description: _interpolateString(description, interpolateData),
      releaseNotesTitle: _interpolateString(releaseNotesTitle, interpolateData),
      releaseNotes: _interpolateString(releaseNotes, interpolateData),
      skipButton: _interpolateString(skipButton, interpolateData),
      postponeButton: _interpolateString(postponeButton, interpolateData),
      updateButton: _interpolateString(updateButton, interpolateData),
      customParams: interpolatedcustomParams,
    );

    return data;
  }

  static T _interpolateString<T extends String?>(
    T text,
    Map<String, String> interpolateData,
  ) {
    if (text == null) return text;

    String str = text;

    for (final entry in interpolateData.entries) {
      final regExp = _regExpForField(entry.key);
      str = str.replaceAll(regExp, entry.value);
    }

    // ignore: avoid-type-casts
    return str as T;
  }

  static RegExp _regExpForField(String name) =>
      RegExp('\\\$$name|{$name}|\\\${$name}');
}
