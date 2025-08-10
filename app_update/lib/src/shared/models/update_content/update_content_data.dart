class UpdateContentData {
  final Uri updateUrl;
  final String title;
  final String description;
  final String releaseNotesTitle;
  final String releaseNotes;
  final String skipButton;
  final String postponeButton;
  final String updateButton;
  final Map<String, dynamic>? customData;

  const UpdateContentData({
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

  UpdateContentData interpolate(Map<String, String> interpolateData) {
    final interpolatedCustomData = customData?.map(
      (key, value) => MapEntry(
        key,
        value is String ? _interpolateString(value, interpolateData) : value,
      ),
    );

    return UpdateContentData(
      updateUrl: updateUrl,
      title: _interpolateString(title, interpolateData),
      description: _interpolateString(description, interpolateData),
      releaseNotesTitle: _interpolateString(releaseNotesTitle, interpolateData),
      releaseNotes: _interpolateString(releaseNotes, interpolateData),
      skipButton: _interpolateString(skipButton, interpolateData),
      postponeButton: _interpolateString(postponeButton, interpolateData),
      updateButton: _interpolateString(updateButton, interpolateData),
      customData: interpolatedCustomData,
    );
  }

  String _interpolateString(String text, Map<String, String> interpolateData) {
    String result = text;
    for (final entry in interpolateData.entries) {
      result = result.replaceAll(_regExpForField(entry.key), entry.value);
    }
    return result;
  }

  RegExp _regExpForField(String name) => RegExp('\$$name|{$name}|\${$name}');
}
